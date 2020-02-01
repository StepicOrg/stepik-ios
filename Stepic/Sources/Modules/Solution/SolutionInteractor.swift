import Foundation
import PromiseKit

protocol SolutionInteractorProtocol {
    func doSolutionLoad(request: Solution.SolutionLoad.Request)
}

final class SolutionInteractor: SolutionInteractorProtocol {
    private let stepID: Step.IdType
    private let submission: Submission
    private let discussionID: DiscussionThread.IdType

    private let presenter: SolutionPresenterProtocol
    private let provider: SolutionProviderProtocol

    init(
        stepID: Step.IdType,
        submission: Submission,
        discussionID: DiscussionThread.IdType,
        presenter: SolutionPresenterProtocol,
        provider: SolutionProviderProtocol
    ) {
        self.stepID = stepID
        self.submission = submission
        self.discussionID = discussionID
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
        }.done { step in
            let response = Solution.SolutionLoad.Data(
                step: step,
                submission: self.submission,
                discussionID: self.discussionID
            )
            self.presenter.presentSolution(response: .init(result: .success(response)))
        }.catch { error in
            self.presenter.presentSolution(response: .init(result: .failure(error)))
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
