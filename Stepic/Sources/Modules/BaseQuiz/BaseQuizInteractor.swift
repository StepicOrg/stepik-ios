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

    private let presenter: BaseQuizPresenterProtocol
    private let provider: BaseQuizProviderProtocol

    let step: Step

    private var submissionsCount = 0
    private var currentAttempt: Attempt?

    init(
        step: Step,
        presenter: BaseQuizPresenterProtocol,
        provider: BaseQuizProviderProtocol
    ) {
        self.step = step
        self.presenter = presenter
        self.provider = provider
    }

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
        }.cauterize()
    }

    func doSubmissionSubmit(request: BaseQuiz.SubmissionSubmit.Request) {
        guard let attempt = self.currentAttempt else {
            // TODO: send analytics for this case
            return
        }

        let queue = DispatchQueue.global(qos: .userInitiated)
        let reply = request.reply

        print("base quiz interactor: creating submission for attempt = \(attempt.id)...")
        queue.promise {
            self.provider.createSubmission(for: self.step, attempt: attempt, reply: reply)
        }.then { submission -> Promise<Submission> in
            guard let submission = submission else {
                throw Error.submissionFetchFailed
            }

            print("base quiz interactor: submission created = \(submission.id), status = \(submission.status)")

            self.submissionsCount += 1
            self.presentSubmission(attempt: attempt, submission: submission, cachedReply: reply)

            print("base quiz interactor: polling submission \(submission.id)...")
            return queue.promise { self.pollSubmission(submission) }
        }.done { submission in
            print("base quiz interactor: submission \(submission.id) completely evaluated")
            self.presentSubmission(attempt: attempt, submission: submission, cachedReply: reply)
        }.cauterize()
    }

    // MARK: - Private API

    private func presentSubmission(attempt: Attempt, submission: Submission?, cachedReply: Reply?) {
        let response = BaseQuiz.SubmissionLoad.Response(
            step: self.step,
            attempt: attempt,
            submission: submission,
            cachedReply: cachedReply,
            submissionsCount: self.submissionsCount
        )

        self.presenter.presentSubmission(response: response)
    }

    private func loadAttempt(forceRefreshAttempt: Bool) -> Promise<Attempt?> {
        return firstly { () -> Promise<Attempt?> in
            if forceRefreshAttempt {
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
