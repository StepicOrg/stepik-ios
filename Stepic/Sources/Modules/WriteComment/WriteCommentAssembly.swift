import UIKit

final class WriteCommentAssembly: Assembly {
    private let targetID: WriteComment.TargetIDType
    private let parentID: WriteComment.ParentIDType?
    private let discussionThreadType: DiscussionThread.ThreadType
    private let presentationContext: WriteComment.PresentationContext
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    private weak var moduleOutput: WriteCommentOutputProtocol?

    init(
        targetID: WriteComment.TargetIDType,
        parentID: WriteComment.ParentIDType? = nil,
        discussionThreadType: DiscussionThread.ThreadType = .default,
        presentationContext: WriteComment.PresentationContext = .create,
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init(),
        output: WriteCommentOutputProtocol? = nil
    ) {
        self.targetID = targetID
        self.parentID = parentID
        self.discussionThreadType = discussionThreadType
        self.presentationContext = presentationContext
        self.navigationBarAppearance = navigationBarAppearance
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = WriteCommentProvider(
            commentsNetworkService: CommentsNetworkService(commentsAPI: CommentsAPI())
        )
        let presenter = WriteCommentPresenter()
        let interactor = WriteCommentInteractor(
            targetID: self.targetID,
            parentID: self.parentID,
            discussionThreadType: self.discussionThreadType,
            presentationContext: self.presentationContext,
            presenter: presenter,
            provider: provider
        )
        let viewController = WriteCommentViewController(
            interactor: interactor,
            appearance: .init(
                navigationBarAppearance: self.navigationBarAppearance
            )
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
