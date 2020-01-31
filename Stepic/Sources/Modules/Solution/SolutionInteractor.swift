import Foundation
import PromiseKit

protocol SolutionInteractorProtocol {
    func doSolutionLoad(request: Solution.SolutionLoad.Request)
}

final class SolutionInteractor: SolutionInteractorProtocol {
    private let stepID: Step.IdType
    private let submissionID: Submission.IdType

    private let presenter: SolutionPresenterProtocol
    private let provider: SolutionProviderProtocol

    init(
        stepID: Step.IdType,
        submissionID: Submission.IdType,
        presenter: SolutionPresenterProtocol,
        provider: SolutionProviderProtocol
    ) {
        self.stepID = stepID
        self.submissionID = submissionID
        self.presenter = presenter
        self.provider = provider
    }

    func doSolutionLoad(request: Solution.SolutionLoad.Request) {
        firstly {
            self.provider.fetchStep(id: self.stepID)
        }.then { fetchResult -> Promise<Step> in
            guard let step = fetchResult.value else {
                throw Error.fetchFailed
            }

            return .value(step)
        }.then { step -> Promise<(Step, Submission?)> in
            self.provider.fetchSubmission(id: self.submissionID, step: step).map { (step, $0) }
        }.then { step, submission -> Promise<(Step, Submission, Attempt?)> in
            guard let submission = submission else {
                throw Error.fetchFailed
            }

            return self.provider.fetchAttempt(id: submission.attemptID, step: step).map { (step, submission, $0) }
        }.done { step, submission, attempt in
            guard let attempt = attempt else {
                throw Error.fetchFailed
            }

            let response = Solution.SolutionLoad.Data(step: step, submission: submission, attempt: attempt)

            self.presenter.presentSolution(response: .init(result: .success(response)))
        }.catch { error in
            self.presenter.presentSolution(response: .init(result: .failure(error)))
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
