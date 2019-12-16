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

    private let originalText: String
    private var currentText: String

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

        switch presentationContext {
        case .create:
            self.originalText = ""
        case .edit(let comment):
            self.originalText = comment.text
        }
        self.currentText = self.originalText
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
        let htmlText = self.currentText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "<br>")
        let currentComment = Comment(parent: self.parentID, target: self.targetID, text: htmlText)

        var actionPromise: Promise<Comment>
        var moduleOutputHandler: ((Comment) -> Void)?

        switch self.presentationContext {
        case .create:
            actionPromise = self.provider.create(comment: currentComment)
            moduleOutputHandler = self.moduleOutput?.handleCommentCreated(_:)
        case .edit(let comment):
            currentComment.id = comment.id
            actionPromise = self.provider.update(comment: currentComment)
            moduleOutputHandler = self.moduleOutput?.handleCommentUpdated(_:)
        }

        actionPromise.done { comment in
            self.currentText = comment.text.replacingOccurrences(of: "<br>", with: "\n")
            self.presenter.presentCommentMainActionResult(
                response: WriteComment.CommentMainAction.Response(
                    data: .success(self.makeCommentInfo())
                )
            )
            moduleOutputHandler?(comment)
        }.catch { error in
            self.presenter.presentCommentMainActionResult(
                response: WriteComment.CommentMainAction.Response(data: .failure(error))
            )
        }
    }

    func doCommentCancelPresentation(request: WriteComment.CommentCancelPresentation.Request) {
        self.presenter.presentCommentCancelPresentation(
            response: WriteComment.CommentCancelPresentation.Response(
                originalText: self.originalText,
                currentText: self.currentText
            )
        )
    }

    // MARK: - Private API

    private func makeCommentInfo() -> WriteComment.CommentInfo {
        WriteComment.CommentInfo(
            text: self.currentText,
            presentationContext: self.presentationContext
        )
    }
}
