import Foundation
import PromiseKit

protocol SolutionInteractorProtocol {
    func doSolutionLoad(request: Solution.SolutionLoad.Request)
}

final class SolutionInteractor: SolutionInteractorProtocol {
    private let stepID: Step.IdType
    private let submission: Submission

    private let presenter: SolutionPresenterProtocol
    private let provider: SolutionProviderProtocol

    init(
        stepID: Step.IdType,
        submission: Submission,
        presenter: SolutionPresenterProtocol,
        provider: SolutionProviderProtocol
    ) {
        self.stepID = stepID
        self.submission = submission
        self.presenter = presenter
        self.provider = provider
    }

    func doSolutionLoad(request: Solution.SolutionLoad.Request) {
        firstly {
            self.provider.fetchStep(id: self.stepID).compactMap { $0.value }
        }.then { step -> Promise<(Step, URL?)> in
            self.provider.getSubmissionURL().map { (step, $0) }
        }.done { step, submissionURL in
            let response = Solution.SolutionLoad.Data(
                step: step,
                submission: self.submission,
                submissionURL: submissionURL
            )
            self.presenter.presentSolution(response: .init(result: .success(response)))
        }.catch { error in
            self.presenter.presentSolution(response: .init(result: .failure(error)))
        }
    }
}
