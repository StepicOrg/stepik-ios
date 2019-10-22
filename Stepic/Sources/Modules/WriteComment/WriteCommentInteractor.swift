import Foundation
import PromiseKit

protocol WriteCommentInteractorProtocol {
    func doCommentLoad(request: WriteComment.CommentLoad.Request)
}

final class WriteCommentInteractor: WriteCommentInteractorProtocol {
    weak var moduleOutput: WriteCommentOutputProtocol?

    private let targetID: WriteComment.TargetIDType
    private let parentID: WriteComment.ParentIDtype?
    private let presentationContext: WriteComment.PresentationContext

    private let presenter: WriteCommentPresenterProtocol
    private let provider: WriteCommentProviderProtocol

    private var currentText: String = ""

    init(
        targetID: WriteComment.TargetIDType,
        parentID: WriteComment.ParentIDtype?,
        presentationContext: WriteComment.PresentationContext,
        presenter: WriteCommentPresenterProtocol,
        provider: WriteCommentProviderProtocol
    ) {
        self.targetID = targetID
        self.parentID = parentID
        self.presentationContext = presentationContext
        self.presenter = presenter
        self.provider = provider
    }

    func doCommentLoad(request: WriteComment.CommentLoad.Request) {
        self.presenter.presentComment(
            response: WriteComment.CommentLoad.Response(result: self.makeCommentInfo())
        )
    }

    // MARK: - Private API

    private func makeCommentInfo() -> WriteComment.CommentInfo {
        return WriteComment.CommentInfo(
            text: self.currentText,
            presentationContext: self.presentationContext
        )
    }
}
