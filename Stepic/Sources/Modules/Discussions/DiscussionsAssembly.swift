import UIKit

final class DiscussionsAssembly: Assembly {
    private let discussionProxyID: DiscussionProxy.IdType
    private let stepID: Step.IdType
    private let presentationContext: Discussions.PresentationContext

    init(
        discussionProxyID: DiscussionProxy.IdType,
        stepID: Step.IdType,
        presentationContext: Discussions.PresentationContext = .fromBeginning
    ) {
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
        self.presentationContext = presentationContext
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
            stepID: self.stepID,
            presentationContext: self.presentationContext,
            presenter: presenter,
            provider: provider
        )
        let viewController = DiscussionsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
