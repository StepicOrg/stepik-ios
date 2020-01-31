import UIKit

final class DiscussionsAssembly: Assembly {
    var moduleInput: DiscussionsInputProtocol?

    private let threadType: DiscussionThread.ThreadType
    private let discussionProxyID: DiscussionProxy.IdType
    private let stepID: Step.IdType
    private let presentationContext: Discussions.PresentationContext

    init(
        threadType: DiscussionThread.ThreadType,
        discussionProxyID: DiscussionProxy.IdType,
        stepID: Step.IdType,
        presentationContext: Discussions.PresentationContext = .fromBeginning
    ) {
        self.threadType = threadType
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
            threadType: self.threadType,
            discussionProxyID: self.discussionProxyID,
            stepID: self.stepID,
            presentationContext: self.presentationContext,
            presenter: presenter,
            provider: provider,
            discussionsSortTypeStorageManager: DiscussionsSortTypeStorageManager()
        )
        let viewController = DiscussionsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
