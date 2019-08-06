import Foundation
import PromiseKit

protocol BaseQuizInteractorProtocol {
    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request)
    func doSubmissionSubmit(request: BaseQuiz.SubmissionSubmit.Request)
    func doReplyCache(request: BaseQuiz.ReplyCache.Request)
}

final class BaseQuizInteractor: BaseQuizInteractorProtocol {
    private static let pollInterval: TimeInterval = 0.5

    weak var moduleOutput: BaseQuizOutputProtocol?

    private let userService: UserAccountServiceProtocol
    private let presenter: BaseQuizPresenterProtocol
    private let provider: BaseQuizProviderProtocol

    // Legacy dependencies
    private let notificationSuggestionManager: NotificationSuggestionManager
    private let rateAppManager: RateAppManager

    let step: Step

    private var submissionsCount = 0
    private var currentAttempt: Attempt?

    init(
        step: Step,
        presenter: BaseQuizPresenterProtocol,
        provider: BaseQuizProviderProtocol,
        notificationSuggestionManager: NotificationSuggestionManager,
        rateAppManager: RateAppManager,
        userService: UserAccountServiceProtocol
    ) {
        self.step = step
        self.presenter = presenter
        self.provider = provider
        self.userService = userService

        self.notificationSuggestionManager = notificationSuggestionManager
        self.rateAppManager = rateAppManager
    }

    // TODO: Cache reply, currently unused.
    func doReplyCache(request: BaseQuiz.ReplyCache.Request) {
        guard let attempt = self.currentAttempt else {
            return
        }

        // FIXME: DI
        ReplyCache.shared.set(reply: request.reply, forStepId: self.step.id, attemptId: attempt.id)
    }

    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request) {
        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.loadAttempt(forceRefreshAttempt: request.shouldRefreshAttempt)
        }.then(on: queue) { attempt -> Promise<(Attempt, Submission?)> in
            guard let attempt = attempt else {
                throw Error.unknownAttempt
            }

            return self.provider.fetchSubmissions(for: self.step, attempt: attempt).map { (attempt, $0.0.first) }
        }.then(on: queue) { attempt, submission -> Guarantee<(Attempt, Submission?, Reply?, Int)> in
            let cachedReply = ReplyCache.shared.getReply(forStepId: self.step.id, attemptId: attempt.id)
            return (self.step.hasSubmissionRestrictions ? self.countSubmissions() : Guarantee.value(0))
                .map { (attempt, submission, cachedReply, $0) }
        }.done { attempt, submission, cachedReply, submissionLimit in
            self.submissionsCount = submissionLimit
            self.currentAttempt = attempt

            self.presentSubmission(attempt: attempt, submission: submission, cachedReply: cachedReply)
        }.catch { error in
            print("base quiz interactor: error while load submission = \(error.localizedDescription)")
            self.presenter.presentSubmission(response: .init(result: .failure(error)))
        }
    }

    func doSubmissionSubmit(request: BaseQuiz.SubmissionSubmit.Request) {
        guard let attempt = self.currentAttempt else {
            // TODO: send analytics for this case
            return
        }

        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.submit, parameters: nil)

        let queue = DispatchQueue.global(qos: .userInitiated)
        let reply = request.reply

        print("base quiz interactor: creating submission for attempt = \(attempt.id)...")
        queue.promise {
            self.provider.createSubmission(for: self.step, attempt: attempt, reply: reply)
        }.then { submission -> Promise<Submission> in
            guard let submission = submission else {
                throw Error.submissionFetchFailed
            }

            print("base quiz interactor: submission created = \(submission.id), status = \(submission.status ??? "")")

            // Analytics
            AnalyticsUserProperties.shared.incrementSubmissionsCount()
            if let codeReply = reply as? CodeReply {
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Step.Submission.created,
                    parameters: ["type": self.step.block.name, "language": codeReply.languageName]
                )
                AmplitudeAnalyticsEvents.Steps.submissionMade(
                    step: self.step.id,
                    type: self.step.block.name,
                    language: codeReply.languageName
                ).send()
            } else {
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Step.Submission.created,
                    parameters: ["type": self.step.block.name]
                )
                AmplitudeAnalyticsEvents.Steps.submissionMade(
                    step: self.step.id,
                    type: self.step.block.name
                ).send()
            }

            self.submissionsCount += 1
            self.presentSubmission(attempt: attempt, submission: submission, cachedReply: reply)

            print("base quiz interactor: polling submission \(submission.id)...")
            return queue.promise { self.pollSubmission(submission) }
        }.done { submission in
            print("base quiz interactor: submission \(submission.id) completely evaluated")

            self.presentSubmission(attempt: attempt, submission: submission, cachedReply: reply)

            if submission.status == "correct" {
                self.moduleOutput?.handleCorrectSubmission()

                if self.suggestRateAppIfNeeded() {
                    return
                }

                self.suggestStreakIfNeeded()
            }
        }.catch { error in
            print("base quiz interactor: error while submission = \(error.localizedDescription)")
            self.presenter.presentSubmission(response: .init(result: .failure(error)))
        }
    }

    // MARK: - Private API

    @discardableResult
    private func suggestStreakIfNeeded() -> Bool {
        guard self.notificationSuggestionManager.canShowAlert(context: .streak, after: .submission) else {
            return false
        }

        guard let userID = self.userService.currentUser?.id else {
            return false
        }

        DispatchQueue.global(qos: .userInitiated).promise {
            self.provider.fetchActivity(for: userID)
        }.done { userActivity in
            if userActivity.currentStreak > 0 {
                self.presenter.presentStreakAlert(response: .init(streak: userActivity.currentStreak))
            }
        }.cauterize()

        return true
    }

    @discardableResult
    private func suggestRateAppIfNeeded() -> Bool {
        if self.rateAppManager.submittedCorrect() {
            self.presenter.presentRateAppAlert(response: .init())
            return true
        }

        return false
    }

    private func presentSubmission(attempt: Attempt, submission: Submission?, cachedReply: Reply?) {
        let response = BaseQuiz.SubmissionLoad.Data(
            step: self.step,
            attempt: attempt,
            submission: submission,
            cachedReply: cachedReply,
            submissionsCount: self.submissionsCount
        )

        self.presenter.presentSubmission(response: .init(result: .success(response)))
    }

    private func loadAttempt(forceRefreshAttempt: Bool) -> Promise<Attempt?> {
        return firstly { () -> Promise<Attempt?> in
            if forceRefreshAttempt {
                AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.newAttempt, parameters: nil)

                return self.provider.createAttempt(for: self.step)
            }
            return self.provider.fetchAttempts(for: self.step).map { $0.0.first }
        }.then { attempt -> Promise<Attempt?> in
            guard let attempt = attempt, attempt.status == "active" else {
                return self.provider.createAttempt(for: self.step)
            }

            return .value(attempt)
        }
    }

    private func countSubmissions() -> Guarantee<Int> {
        return Guarantee { seal in
            var count = 0
            func loadSubmissions(page: Int) {
                self.provider.fetchSubmissions(for: self.step, page: page).done { submissions, meta in
                    count += submissions.count

                    if meta.hasNext {
                        loadSubmissions(page: page + 1)
                    } else {
                        seal(count)
                    }
                }.catch { _ in
                    seal(0)
                }
            }
            loadSubmissions(page: 1)
        }
    }

    private func pollSubmission(_ submission: Submission) -> Promise<Submission> {
        return Promise { seal in
            func poll(retryCount: Int) {
                after(seconds: Double(retryCount) * BaseQuizInteractor.pollInterval).then {
                    _ -> Promise<Submission?> in

                    self.provider.fetchSubmission(id: submission.id, step: self.step)
                }.done { submission in
                    guard let submission = submission else {
                        throw Error.submissionFetchFailed
                    }

                    if submission.status == "evaluation" {
                        poll(retryCount: retryCount + 1)
                    } else {
                        seal.fulfill(submission)
                    }
                }.catch { error in
                    print("base quiz interactor: error while polling submission = \(error)")
                    seal.reject(Error.submissionFetchFailed)
                }
            }

            poll(retryCount: 1)
        }
    }

    enum Error: Swift.Error {
        case unknownAttempt
        case attemptFetchFailed
        case submissionFetchFailed
    }
}
