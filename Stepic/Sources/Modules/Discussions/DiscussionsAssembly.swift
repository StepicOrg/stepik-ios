import UIKit

final class DiscussionsAssembly: Assembly {
    private let discussionProxyID: DiscussionProxy.IdType
    private let stepID: Step.IdType

    init(discussionProxyID: DiscussionProxy.IdType, stepID: Step.IdType) {
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
    }

    func makeModule() -> UIViewController {
        let provider = DiscussionsProvider(
            discussionProxiesNetworkService: DiscussionProxiesNetworkService(
                discussionProxiesAPI: DiscussionProxiesAPI()
            ),
            commentsNetworkService: CommentsNetworkService(commentsAPI: CommentsAPI()),
            votesNetworkService: VotesNetworkService(votesAPI: VotesAPI()),
            stepsPersistenceService: StepsPersistenceService()
        )
        let presenter = DiscussionsPresenter()
        let interactor = DiscussionsInteractor(
            discussionProxyID: self.discussionProxyID,
            stepID: stepID,
            presenter: presenter,
            provider: provider
        )
        let viewController = DiscussionsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
