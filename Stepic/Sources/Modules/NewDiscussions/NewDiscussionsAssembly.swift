import UIKit

final class NewDiscussionsAssembly: Assembly {
    private let discussionProxyID: DiscussionProxy.IdType

    init(discussionProxyID: DiscussionProxy.IdType) {
        self.discussionProxyID = discussionProxyID
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
            presenter: presenter,
            provider: provider
        )
        let viewController = NewDiscussionsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
