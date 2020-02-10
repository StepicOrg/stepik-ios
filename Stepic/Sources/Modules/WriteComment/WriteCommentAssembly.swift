import UIKit

final class WriteCommentAssembly: Assembly {
    private let targetID: WriteComment.TargetIDType
    private let parentID: WriteComment.ParentIDType?
    private var comment: Comment?
    private var submission: Submission?
    private let discussionThreadType: DiscussionThread.ThreadType
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    private weak var moduleOutput: WriteCommentOutputProtocol?

    init(
        targetID: WriteComment.TargetIDType,
        parentID: WriteComment.ParentIDType? = nil,
        comment: Comment? = nil,
        submission: Submission? = nil,
        discussionThreadType: DiscussionThread.ThreadType = .default,
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init(),
        output: WriteCommentOutputProtocol? = nil
    ) {
        self.targetID = targetID
        self.parentID = parentID
        self.comment = comment
        self.submission = submission
        self.discussionThreadType = discussionThreadType
        self.navigationBarAppearance = navigationBarAppearance
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = WriteCommentProvider(
            commentsNetworkService: CommentsNetworkService(commentsAPI: CommentsAPI()),
            stepsNetworkService: StepsNetworkService(stepsAPI: StepsAPI()),
            stepsPersistenceService: StepsPersistenceService()
        )
        let presenter = WriteCommentPresenter()
        let interactor = WriteCommentInteractor(
            targetID: self.targetID,
            parentID: self.parentID,
            comment: self.comment,
            submission: self.submission,
            discussionThreadType: self.discussionThreadType,
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
