import Foundation
import PromiseKit

protocol WriteCommentInteractorProtocol {
    func doCommentLoad(request: WriteComment.CommentLoad.Request)
    func doCommentTextUpdate(request: WriteComment.CommentTextUpdate.Request)
    func doCommentMainAction(request: WriteComment.CommentMainAction.Request)
    func doCommentCancelPresentation(request: WriteComment.CommentCancelPresentation.Request)
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
            response: WriteComment.CommentLoad.Response(data: self.makeCommentInfo())
        )
    }

    func doCommentTextUpdate(request: WriteComment.CommentTextUpdate.Request) {
        self.currentText = request.text

        self.presenter.presentCommentTextUpdate(
            response: WriteComment.CommentTextUpdate.Response(data: self.makeCommentInfo())
        )
    }

    func doCommentMainAction(request: WriteComment.CommentMainAction.Request) {
        switch self.presentationContext {
        case .create:
            self.createComment()
        case .edit:
            break
        }
    }

    func doCommentCancelPresentation(request: WriteComment.CommentCancelPresentation.Request) {
        self.presenter.presentCommentCancelPresentation(
            response: WriteComment.CommentCancelPresentation.Response(
                originalText: "",
                currentText: self.currentText
            )
        )
    }

    // MARK: - Private API

    private func createComment() {
        let htmlText = self.currentText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "<br>")

        self.provider.create(
            targetID: self.targetID,
            parentID: self.parentID,
            text: htmlText
        ).done { comment in
            self.currentText = comment.text.replacingOccurrences(of: "<br>", with: "\n")
            self.presenter.presentCommentMainActionResult(
                response: WriteComment.CommentMainAction.Response(
                    data: .success(self.makeCommentInfo())
                )
            )
            self.moduleOutput?.handleCommentCreated(comment)
        }.catch { error in
            self.presenter.presentCommentMainActionResult(
                response: WriteComment.CommentMainAction.Response(data: .failure(error))
            )
        }
    }

    private func makeCommentInfo() -> WriteComment.CommentInfo {
        return WriteComment.CommentInfo(
            text: self.currentText,
            presentationContext: self.presentationContext
        )
    }
}
