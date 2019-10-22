import UIKit

final class WriteCommentAssembly: Assembly {
    private let targetID: WriteComment.TargetIDType
    private let parentID: WriteComment.ParentIDtype?
    private let presentationContext: WriteComment.PresentationContext

    private weak var moduleOutput: WriteCommentOutputProtocol?

    init(
        targetID: WriteComment.TargetIDType,
        parentID: WriteComment.ParentIDtype? = nil,
        presentationContext: WriteComment.PresentationContext = .create,
        output: WriteCommentOutputProtocol? = nil
    ) {
        assert(targetID != parentID)

        if presentationContext == .edit {
            fatalError("not implemented yet")
        }

        self.targetID = targetID
        self.parentID = parentID
        self.presentationContext = presentationContext
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = WriteCommentProvider()
        let presenter = WriteCommentPresenter()
        let interactor = WriteCommentInteractor(
            targetID: self.targetID,
            parentID: self.parentID,
            presentationContext: self.presentationContext,
            presenter: presenter,
            provider: provider
        )
        let viewController = WriteCommentViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
