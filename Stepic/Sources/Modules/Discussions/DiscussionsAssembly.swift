import UIKit

final class DiscussionsAssembly: Assembly {
    var moduleInput: DiscussionsInputProtocol?

    private let discussionThreadType: DiscussionThread.ThreadType
    private let discussionProxyID: DiscussionProxy.IdType
    private let stepID: Step.IdType
    private let isTeacher: Bool
    private let presentationContext: Discussions.PresentationContext

    init(
        discussionThreadType: DiscussionThread.ThreadType,
        discussionProxyID: DiscussionProxy.IdType,
        stepID: Step.IdType,
        isTeacher: Bool,
        presentationContext: Discussions.PresentationContext = .fromBeginning
    ) {
        self.discussionThreadType = discussionThreadType
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
        self.isTeacher = isTeacher
        self.presentationContext = presentationContext
    }

    func makeModule() -> UIViewController {
        let provider = DiscussionsProvider(
            discussionProxiesNetworkService: DiscussionProxiesNetworkService(
                discussionProxiesAPI: DiscussionProxiesAPI()
            ),
            commentsNetworkService: CommentsNetworkService(commentsAPI: CommentsAPI()),
            votesNetworkService: VotesNetworkService(votesAPI: VotesAPI()),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            stepsPersistenceService: StepsPersistenceService()
        )
        let presenter = DiscussionsPresenter()
        let interactor = DiscussionsInteractor(
            discussionThreadType: self.discussionThreadType,
            discussionProxyID: self.discussionProxyID,
            stepID: self.stepID,
            isTeacher: self.isTeacher,
            presentationContext: self.presentationContext,
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared,
            discussionsSortTypeStorageManager: DiscussionsSortTypeStorageManager()
        )
        let viewController = DiscussionsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
