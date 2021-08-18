import Foundation
import PromiseKit

protocol BaseQuizInteractorProtocol {
    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request)
    func doSubmissionSubmit(request: BaseQuiz.SubmissionSubmit.Request)
    func doRetryPollSubmission(request: BaseQuiz.RetryPollSubmission.Request)
    func doReplyCache(request: BaseQuiz.ReplyCache.Request)
    func doNextStepNavigationRequest(request: BaseQuiz.NextStepNavigation.Request)
}

final class BaseQuizInteractor: BaseQuizInteractorProtocol {
    private static let pollInterval: TimeInterval = 0.5

    weak var moduleOutput: BaseQuizOutputProtocol?

    private let userAccountService: UserAccountServiceProtocol
    private let presenter: BaseQuizPresenterProtocol
    private let provider: BaseQuizProviderProtocol
    private let analytics: Analytics

    // Legacy dependencies
    private let notificationSuggestionManager: NotificationSuggestionManager
    private let rateAppManager: RateAppManager
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol

    let step: Step
    private let hasNextStep: Bool

    private var submissionsCount = 0
    private var currentAttempt: Attempt?
    private var currentSubmission: Submission?

    private var isFirstSubmissionLoad = true

    private var cacheReplyQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.BaseQuizInteractor.CacheReply",
        qos: .userInitiated
    )

    init(
        step: Step,
        hasNextStep: Bool,
        presenter: BaseQuizPresenterProtocol,
        provider: BaseQuizProviderProtocol,
        analytics: Analytics,
        notificationSuggestionManager: NotificationSuggestionManager,
        rateAppManager: RateAppManager,
        userAccountService: UserAccountServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol
    ) {
        self.step = step
        self.hasNextStep = hasNextStep
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.analytics = analytics

        self.notificationSuggestionManager = notificationSuggestionManager
        self.rateAppManager = rateAppManager
        self.adaptiveStorageManager = adaptiveStorageManager
    }

    // MARK: Protocol Conforming

    func doReplyCache(request: BaseQuiz.ReplyCache.Request) {
        guard let attempt = self.currentAttempt,
              let submission = self.currentSubmission else {
            return
        }

        // TODO: When submission is in wrong status it's better to show retry button instead of allow editing reply,
        // then handle on tap retry, create attempt and create local submission with +1 id if submission exists.
        let localSubmission = Submission(submission: submission)
        localSubmission.id += submission.status == .wrong && !submission.isLocal ? 1 : 0
        localSubmission.attemptID = attempt.id
        localSubmission.reply = request.reply
        localSubmission.isLocal = true

        self.currentSubmission = localSubmission

        self.cacheReplyQueue.async { [weak self] in
            self?.provider
                .createLocalSubmission(localSubmission)
                .done { _ in }
        }
    }

    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request) {
        let isFirstSubmissionLoad = self.isFirstSubmissionLoad
        self.isFirstSubmissionLoad = false

        if isFirstSubmissionLoad && !request.shouldRefreshAttempt {
            self.fetchSubmissionDataFromCache().done { cachedAttempt, cachedSubmission, cachedSubmissionsCount in
                self.moduleOutput?.handleQuizLoaded(
                    attempt: cachedAttempt,
                    submission: cachedSubmission,
                    submissionsCount: cachedSubmissionsCount,
                    source: .cache
                )

                self.presentSubmission(attempt: cachedAttempt, submission: cachedSubmission)

                self.fetchSubmissionDataFromRemote(
                    forceRefreshAttempt: false
                ).done { remoteAttempt, remoteSubmission, remoteSubmissionsCount in
                    self.moduleOutput?.handleQuizLoaded(
                        attempt: remoteAttempt,
                        submission: remoteSubmission,
                        submissionsCount: remoteSubmissionsCount,
                        source: .remote
                    )

                    let shouldReload = cachedAttempt != remoteAttempt
                        || cachedSubmission != remoteSubmission
                        || cachedSubmissionsCount != remoteSubmissionsCount
                    if shouldReload {
                        self.presentSubmission(attempt: remoteAttempt, submission: remoteSubmission)
                    }
                }.cauterize()
            }.catch { _ in
                self.fetchSubmissionDataFromRemote(
                    forceRefreshAttempt: false
                ).done { attempt, submission, submissionsCount in
                    self.moduleOutput?.handleQuizLoaded(
                        attempt: attempt,
                        submission: submission,
                        submissionsCount: submissionsCount,
                        source: .remote
                    )

                    self.presentSubmission(attempt: attempt, submission: submission)
                }.catch { error in
                    self.presenter.presentSubmission(response: .init(result: .failure(error)))
                }
            }
        } else {
            self.fetchSubmissionDataFromRemote(
                forceRefreshAttempt: request.shouldRefreshAttempt
            ).done { attempt, submission, submissionsCount in
                self.moduleOutput?.handleQuizLoaded(
                    attempt: attempt,
                    submission: submission,
                    submissionsCount: submissionsCount,
                    source: .remote
                )

                self.presentSubmission(attempt: attempt, submission: submission)
            }.catch { error in
                self.presenter.presentSubmission(response: .init(result: .failure(error)))
            }
        }
    }

    func doSubmissionSubmit(request: BaseQuiz.SubmissionSubmit.Request) {
        guard let attempt = self.currentAttempt,
              let submission = self.currentSubmission else {
            return
        }

        let reply = request.reply

        // Present evaluation status
        let evaluationSubmission = Submission(submission: submission)
        evaluationSubmission.reply = request.reply
        evaluationSubmission.status = .evaluation
        self.presentSubmission(attempt: attempt, submission: evaluationSubmission)

        print("BaseQuizInteractor: creating submission for attempt = \(attempt.id)...")
        self.analytics.send(.submitSubmissionTapped(parameters: nil))

        firstly {
            self.provider.createSubmission(for: self.step, attempt: attempt, reply: reply)
        }.then { submission -> Promise<Submission> in
            guard let submission = submission else {
                throw Error.submissionFetchFailed
            }

            print("BaseQuizInteractor: submission created = \(submission.id), status = \(submission.statusString ??? "")")

            let isAdaptive: Bool? = {
                if let course = LastStepGlobalContext.context.course {
                    return self.adaptiveStorageManager.supportedInAdaptiveModeCoursesIDs.contains(course.id)
                }
                return nil
            }()
            let codeLanguageName: String? = (reply as? CodeReply)?.languageName
            self.analytics.send(
                .submissionMade(
                    stepID: self.step.id,
                    submissionID: submission.id,
                    blockName: self.step.block.name,
                    isAdaptive: isAdaptive,
                    codeLanguageName: codeLanguageName
                )
            )
            AnalyticsUserProperties.shared.incrementSubmissionsCount()

            self.submissionsCount += 1
            self.currentSubmission = submission
            self.presentSubmission(attempt: attempt, submission: submission)

            print("BaseQuizInteractor: polling submission \(submission.id)...")
            return self.pollSubmission(submission)
        }.done { submission in
            print("BaseQuizInteractor: submission \(submission.id) completely evaluated")
            self.handleSubmissionEvaluated(attempt: attempt, submission: submission)
        }.catch { error in
            print("BaseQuizInteractor: error while evaluating submission = \(error)")
            self.presenter.presentSubmission(response: .init(result: .failure(error)))
        }
    }

    func doRetryPollSubmission(request: BaseQuiz.RetryPollSubmission.Request) {
        guard let attempt = self.currentAttempt,
              let submission = self.currentSubmission else {
            return
        }

        self.pollSubmission(submission).done { submission in
            print("BaseQuizInteractor: submission \(submission.id) completely evaluated")
            self.handleSubmissionEvaluated(attempt: attempt, submission: submission)
        }.catch { error in
            print("BaseQuizInteractor: error while evaluating submission = \(error)")
            self.presenter.presentSubmission(response: .init(result: .failure(error)))
        }
    }

    func doNextStepNavigationRequest(request: BaseQuiz.NextStepNavigation.Request) {
        self.moduleOutput?.handleNextStepNavigation()
    }

    // MARK: Private API

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

    private func fetchSubmissionDataFromCache() -> Promise<(Attempt, Submission, Int)> {
        Promise { seal in
            firstly { () -> Promise<([Attempt], Meta)> in
                self.provider.fetchCachedStepAttempts(stepID: self.step.id)
            }.then { attempts, _ -> Promise<Attempt> in
                if let activeAttempt = attempts.first(where: { $0.status == "active" }) {
                    return .value(activeAttempt)
                }
                throw Error.noCachedAttempt
            }.then { attempt -> Promise<(Attempt, [Submission])> in
                self.provider.fetchSubmissionsForAttempt(
                    attemptID: attempt.id,
                    stepBlockName: self.step.block.name,
                    dataSourceType: .cache
                ).map { (attempt, $0) }
            }.then { attempt, submissions -> Promise<(Attempt, Submission)> in
                if let cachedSubmission = submissions.first {
                    return .value((attempt, cachedSubmission))
                } else {
                    return self.provider
                        .createLocalSubmission(Submission(id: 0, attemptID: attempt.id, isLocal: true))
                        .map { (attempt, $0) }
                }
            }.then { attempt, submission -> Guarantee<(Attempt, Submission, Int)> in
                self.countSubmissions(dataSourceType: .cache)
                    .map { (attempt, submission, $0) }
            }.done { attempt, submission, submissionLimit in
                self.submissionsCount = submissionLimit
                self.currentAttempt = attempt
                self.currentSubmission = submission

                seal.fulfill((attempt, submission, submissionLimit))
            }.catch { error in
                print("BaseQuizInteractor: error while load cached submission = \(error)")
                seal.reject(error)
            }
        }
    }

    private func fetchSubmissionDataFromRemote(forceRefreshAttempt: Bool) -> Promise<(Attempt, Submission, Int)> {
        Promise { seal in
            firstly {
                self.fetchAttempt(forceRefreshAttempt: forceRefreshAttempt)
                    .compactMap { $0 }
            }.then { attempt -> Promise<(Attempt, Submission)> in
                self.fetchSubmission(attemptID: attempt.id)
                    .map { (attempt, $0) }
            }.then { attempt, submission -> Guarantee<(Attempt, Submission, Int)> in
                self.countSubmissions(dataSourceType: .remote)
                    .map { (attempt, submission, $0) }
            }.done { attempt, submission, submissionLimit in
                submission.attempt = attempt

                self.submissionsCount = submissionLimit
                self.currentAttempt = attempt
                self.currentSubmission = submission

                seal.fulfill((attempt, submission, submissionLimit))
            }.catch { error in
                print("BaseQuizInteractor: error while load submission = \(error)")
                seal.reject(error)
            }
        }
    }

    private func fetchAttempt(forceRefreshAttempt: Bool) -> Promise<Attempt?> {
        guard let userID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.unknownUser)
        }

        return firstly { () -> Promise<Attempt?> in
            if forceRefreshAttempt {
                self.analytics.send(.generateNewAttemptTapped)
                return self.provider.createAttempt(for: self.step)
            } else {
                return self.provider
                    .fetchAttempts(for: self.step, userID: userID)
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
            ).done { remoteSubmissions, cachedSubmissions in
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
                    self.provider
                        .createLocalSubmission(Submission(id: 0, attemptID: attemptID, isLocal: true))
                        .done { seal.fulfill($0) }
                }
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func countSubmissions(dataSourceType: DataSourceType) -> Guarantee<Int> {
        Guarantee { seal in
            self.provider
                .fetchSubmissions(for: self.step, page: 1, dataSourceType: dataSourceType)
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
                        throw Error.submissionPollFailed
                    }

                    if submission.status == .evaluation {
                        poll(retryCount: retryCount + 1)
                    } else {
                        seal.fulfill(submission)
                    }
                }.catch { error in
                    print("BaseQuizInteractor: error while polling submission = \(error)")
                    seal.reject(Error.submissionPollFailed)
                }
            }

            poll(retryCount: 1)
        }
    }

    private func handleSubmissionEvaluated(attempt: Attempt, submission: Submission) {
        print("BaseQuizInteractor: submission \(submission.id) completely evaluated")

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
    }

    @discardableResult
    private func suggestStreakIfNeeded() -> Bool {
        guard self.notificationSuggestionManager.canShowAlert(context: .streak, after: .submission) else {
            return false
        }

        guard let userID = self.userAccountService.currentUser?.id else {
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

    // MARK: Inner Types

    enum Error: Swift.Error {
        case unknownAttempt
        case attemptFetchFailed
        case noCachedAttempt
        case submissionFetchFailed
        case submissionPollFailed
        case unknownUser
    }
}
