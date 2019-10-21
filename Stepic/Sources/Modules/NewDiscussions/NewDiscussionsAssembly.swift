import UIKit

final class NewDiscussionsAssembly: Assembly {
    private let discussionProxyID: DiscussionProxy.IdType
    private let stepID: Step.IdType

    init(discussionProxyID: DiscussionProxy.IdType, stepID: Step.IdType) {
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
    }

    func makeModule() -> UIViewController {
        let provider = NewDiscussionsProvider(
            discussionProxiesNetworkService: DiscussionProxiesNetworkService(
                discussionProxiesAPI: DiscussionProxiesAPI()
            ),
            commentsNetworkService: CommentsNetworkService(commentsAPI: CommentsAPI())
        )
        let presenter = NewDiscussionsPresenter()
        let interactor = NewDiscussionsInteractor(
            discussionProxyID: self.discussionProxyID,
            stepID: stepID,
            presenter: presenter,
            provider: provider
        )
        let viewController = NewDiscussionsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
