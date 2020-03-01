import Foundation
import Logging
import PromiseKit

protocol BaseQuizInteractorProtocol {
    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request)
    func doSubmissionSubmit(request: BaseQuiz.SubmissionSubmit.Request)
    func doReplyCache(request: BaseQuiz.ReplyCache.Request)
    func doNextStepNavigationRequest(request: BaseQuiz.NextStepNavigation.Request)
}

final class BaseQuizInteractor: BaseQuizInteractorProtocol {
    private static let logger = Logger(label: "com.AlexKarpov.Stepic.BaseQuizInteractor")
    private static let pollInterval: TimeInterval = 0.5

    weak var moduleOutput: BaseQuizOutputProtocol?

    private let userService: UserAccountServiceProtocol
    private let presenter: BaseQuizPresenterProtocol
    private let provider: BaseQuizProviderProtocol

    // Legacy dependencies
    private let notificationSuggestionManager: NotificationSuggestionManager
    private let rateAppManager: RateAppManager

    let step: Step
    private let hasNextStep: Bool

    private var submissionsCount = 0
    private var currentAttempt: Attempt?
    private var currentSubmission: Submission?

    private var cacheReplyQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.BaseQuizInteractor.CacheReply",
        qos: .userInitiated
    )

    init(
        step: Step,
        hasNextStep: Bool,
        presenter: BaseQuizPresenterProtocol,
        provider: BaseQuizProviderProtocol,
        notificationSuggestionManager: NotificationSuggestionManager,
        rateAppManager: RateAppManager,
        userService: UserAccountServiceProtocol
    ) {
        self.step = step
        self.hasNextStep = hasNextStep
        self.presenter = presenter
        self.provider = provider
        self.userService = userService

        self.notificationSuggestionManager = notificationSuggestionManager
        self.rateAppManager = rateAppManager
    }

    func doReplyCache(request: BaseQuiz.ReplyCache.Request) {
        guard let attempt = self.currentAttempt else {
            return
        }

        let submission = Submission(submission: self.currentSubmission)
        submission.attemptID = attempt.id
        submission.reply = request.reply
        submission.submissionStatus = .local

        self.currentSubmission = submission

        self.cacheReplyQueue.async { [weak self] in
            self?.provider
                .createLocalSubmission(submission)
                .done { _ in }
        }
    }

    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request) {
        firstly {
            self.fetchAttempt(forceRefreshAttempt: request.shouldRefreshAttempt)
                .compactMap { $0 }
        }.then { attempt -> Promise<(Attempt, Submission)> in
            self.fetchSubmission(attemptID: attempt.id)
                .map { (attempt, $0) }
        }.then { attempt, submission -> Guarantee<(Attempt, Submission, Int)> in
            self.countSubmissions()
                .map { (attempt, submission, $0) }
        }.done { attempt, submission, submissionLimit in
            self.submissionsCount = submissionLimit
            self.currentAttempt = attempt
            self.currentSubmission = submission

            self.presentSubmission(attempt: attempt, submission: submission)
        }.catch { error in
            Self.logger.error("BaseQuizInteractor: error while load submission = \(error)")
            self.presenter.presentSubmission(response: .init(result: .failure(error)))
        }
    }

    func doSubmissionSubmit(request: BaseQuiz.SubmissionSubmit.Request) {
        guard let attempt = self.currentAttempt,
              let submission = self.currentSubmission else {
            return
        }

        let reply = request.reply
        submission.reply = request.reply
        submission.submissionStatus = .evaluation

        self.presentSubmission(attempt: attempt, submission: submission)

        Self.logger.info("BaseQuizInteractor: creating submission for attempt = \(attempt.id)...")
        AnalyticsEvent.submissionSubmit.report()

        firstly {
            self.provider.createSubmission(for: self.step, attempt: attempt, reply: reply)
        }.then { submission -> Promise<Submission> in
            guard let submission = submission else {
                throw Error.submissionFetchFailed
            }

            Self.logger.info(
                "BaseQuizInteractor: submission created = \(submission.id), status = \(submission.status ??? "")"
            )
            AnalyticsEvent.submissionCreated(reply, self.step).report()

            self.submissionsCount += 1
            self.currentSubmission = submission
            self.presentSubmission(attempt: attempt, submission: submission)

            Self.logger.info("BaseQuizInteractor: polling submission \(submission.id)...")
            return self.pollSubmission(submission)
        }.done { submission in
            Self.logger.info("BaseQuizInteractor: submission \(submission.id) completely evaluated")

            self.currentSubmission = submission
            self.presentSubmission(attempt: attempt, submission: submission)
            self.moduleOutput?.handleSubmissionEvaluated()

            if submission.isCorrect {
                self.moduleOutput?.handleCorrectSubmission()

                if self.suggestRateAppIfNeeded() {
                    return
                }

                self.suggestStreakIfNeeded()
            }
        }.catch { error in
            Self.logger.error("BaseQuizInteractor: error while submission = \(error)")
            self.presenter.presentSubmission(response: .init(result: .failure(error)))
        }
    }

    func doNextStepNavigationRequest(request: BaseQuiz.NextStepNavigation.Request) {
        self.moduleOutput?.handleNextStepNavigation()
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

    private func presentSubmission(attempt: Attempt, submission: Submission) {
        let response = BaseQuiz.SubmissionLoad.Data(
            step: self.step,
            attempt: attempt,
            submission: submission,
            submissionsCount: self.submissionsCount,
            hasNextStep: self.hasNextStep
        )

        self.presenter.presentSubmission(response: .init(result: .success(response)))
    }

    private func fetchAttempt(forceRefreshAttempt: Bool) -> Promise<Attempt?> {
        firstly { () -> Promise<Attempt?> in
            if forceRefreshAttempt {
                AnalyticsEvent.newAttempt.report()
                return self.provider.createAttempt(for: self.step)
            } else {
                return self.provider
                    .fetchAttempts(for: self.step)
                    .map { $0.0.first }
            }
        }.then { attempt -> Promise<Attempt?> in
            guard let attempt = attempt, attempt.status == "active" else {
                return self.provider.createAttempt(for: self.step)
            }

            return .value(attempt)
        }
    }

    private func fetchSubmission(attemptID: Attempt.IdType) -> Promise<Submission> {
        Promise { seal in
            let remoteSubmissionsGuarantee = Guarantee(
                self.provider.fetchSubmissionsForAttempt(
                    attemptID: attemptID,
                    stepBlockName: self.step.block.name,
                    dataSourceType: .remote
                ),
                fallback: nil
            )
            let cacheSubmissionsGuarantee = Guarantee(
                self.provider.fetchSubmissionsForAttempt(
                    attemptID: attemptID,
                    stepBlockName: self.step.block.name,
                    dataSourceType: .cache
                ),
                fallback: nil
            )

            when(
                fulfilled: remoteSubmissionsGuarantee,
                cacheSubmissionsGuarantee
            ).done { (remoteSubmissions: [Submission]?, cachedSubmissions: [Submission]?) in
                let remoteSubmission = remoteSubmissions?.first
                let cachedSubmission = cachedSubmissions?.first

                if let remoteSubmission = remoteSubmission,
                   let cachedSubmission = cachedSubmission {
                    if remoteSubmission.id >= cachedSubmission.id {
                        seal.fulfill(remoteSubmission)
                    } else {
                        seal.fulfill(cachedSubmission)
                    }
                } else if let remoteSubmission = remoteSubmission {
                    seal.fulfill(remoteSubmission)
                } else if let cachedSubmission = cachedSubmission {
                    seal.fulfill(cachedSubmission)
                } else {
                    let submission = Submission(id: 0, status: .local, attemptID: attemptID)
                    self.provider
                        .createLocalSubmission(submission)
                        .done { seal.fulfill($0) }
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func countSubmissions() -> Guarantee<Int> {
        Guarantee { seal in
            self.provider
                .fetchSubmissions(for: self.step, page: 1)
                .map { $0.0.count }
                .done { seal($0) }
                .catch { _ in seal(0) }
        }
    }

    private func pollSubmission(_ submission: Submission) -> Promise<Submission> {
        Promise { seal in
            func poll(retryCount: Int) {
                after(seconds: Double(retryCount) * Self.pollInterval).then { _ -> Promise<Submission?> in
                    self.provider.fetchSubmission(id: submission.id, step: self.step)
                }.done { submission in
                    guard let submission = submission else {
                        throw Error.submissionFetchFailed
                    }

                    if submission.submissionStatus == .evaluation {
                        poll(retryCount: retryCount + 1)
                    } else {
                        seal.fulfill(submission)
                    }
                }.catch { error in
                    Self.logger.error("BaseQuizInteractor: error while polling submission = \(error)")
                    seal.reject(Error.submissionFetchFailed)
                }
            }

            poll(retryCount: 1)
        }
    }

    // MARK: - Inner Types

    enum Error: Swift.Error {
        case unknownAttempt
        case attemptFetchFailed
        case submissionFetchFailed
    }

    private enum AnalyticsEvent {
        case newAttempt
        case submissionSubmit
        case submissionCreated(Reply, Step)

        func report() {
            switch self {
            case .newAttempt:
                AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.newAttempt, parameters: nil)
            case .submissionSubmit:
                AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.submit, parameters: nil)
            case .submissionCreated(let reply, let step):
                AnalyticsUserProperties.shared.incrementSubmissionsCount()
                if let codeReply = reply as? CodeReply {
                    AnalyticsReporter.reportEvent(
                        AnalyticsEvents.Step.Submission.created,
                        parameters: ["type": step.block.name, "language": codeReply.languageName]
                    )
                    AmplitudeAnalyticsEvents.Steps.submissionMade(
                        step: step.id,
                        type: step.block.name,
                        language: codeReply.languageName
                    ).send()
                } else {
                    AnalyticsReporter.reportEvent(
                        AnalyticsEvents.Step.Submission.created,
                        parameters: ["type": step.block.name]
                    )
                    AmplitudeAnalyticsEvents.Steps.submissionMade(
                        step: step.id,
                        type: step.block.name
                    ).send()
                }
            }
        }
    }
}
