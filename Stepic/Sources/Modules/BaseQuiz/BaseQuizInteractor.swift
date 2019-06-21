import Foundation
import PromiseKit

protocol BaseQuizInteractorProtocol {
    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request)
}

final class BaseQuizInteractor: BaseQuizInteractorProtocol {
    private static let pollInterval: TimeInterval = 0.5

    weak var moduleOutput: BaseQuizOutputProtocol?

    private let presenter: BaseQuizPresenterProtocol
    private let provider: BaseQuizProviderProtocol

    let step: Step

    init(
        step: Step,
        presenter: BaseQuizPresenterProtocol,
        provider: BaseQuizProviderProtocol
    ) {
        self.step = step
        self.presenter = presenter
        self.provider = provider
    }

    func doSubmissionLoad(request: BaseQuiz.SubmissionLoad.Request) {
        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.loadAttempt(forceRefreshAttempt: false)
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
            let response = BaseQuiz.SubmissionLoad.Response(
                step: self.step,
                attempt: attempt,
                submission: submission,
                cachedReply: cachedReply,
                submissionsCount: submissionLimit
            )

            self.presenter.presentSubmission(response: response)
        }.cauterize()
    }

    // MARK: - Private API

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
