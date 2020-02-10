import Foundation
import PromiseKit

protocol WriteCommentInteractorProtocol {
    func doCommentLoad(request: WriteComment.CommentLoad.Request)
    func doCommentTextUpdate(request: WriteComment.CommentTextUpdate.Request)
    func doCommentMainAction(request: WriteComment.CommentMainAction.Request)
    func doCommentCancelPresentation(request: WriteComment.CommentCancelPresentation.Request)
    func doSolutionPresentation(request: WriteComment.SolutionPresentation.Request)
    func doSolutionUpdate(request: WriteComment.SolutionUpdate.Request)
}

final class WriteCommentInteractor: WriteCommentInteractorProtocol {
    weak var moduleOutput: WriteCommentOutputProtocol?

    private let targetID: WriteComment.TargetIDType
    private let parentID: WriteComment.ParentIDType?
    private var comment: Comment?
    private var submission: Submission?
    private let discussionThreadType: DiscussionThread.ThreadType

    private let presenter: WriteCommentPresenterProtocol
    private let provider: WriteCommentProviderProtocol

    private var originalSubmissionID: Submission.IdType?
    private var originalText: String { self.comment?.text ?? "" }
    private var currentText = ""

    init(
        targetID: WriteComment.TargetIDType,
        parentID: WriteComment.ParentIDType?,
        comment: Comment?,
        submission: Submission?,
        discussionThreadType: DiscussionThread.ThreadType,
        presenter: WriteCommentPresenterProtocol,
        provider: WriteCommentProviderProtocol
    ) {
        self.targetID = targetID
        self.parentID = parentID
        self.comment = comment
        self.submission = submission
        self.discussionThreadType = discussionThreadType
        self.presenter = presenter
        self.provider = provider

        self.originalSubmissionID = submission?.id
        self.currentText = self.originalText
    }

    // MARK: Protocol Conforming

    func doCommentLoad(request: WriteComment.CommentLoad.Request) {
        self.presenter.presentNavigationItemUpdate(response: .init(discussionThreadType: self.discussionThreadType))
        self.presenter.presentComment(response: .init(data: self.makeCommentData()))
    }

    func doCommentTextUpdate(request: WriteComment.CommentTextUpdate.Request) {
        self.currentText = request.text
        self.presenter.presentCommentTextUpdate(response: .init(data: self.makeCommentData()))
    }

    func doCommentMainAction(request: WriteComment.CommentMainAction.Request) {
        let htmlText = self.currentText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\n", with: "<br>")
        let currentComment = Comment(
            targetID: self.targetID,
            text: htmlText,
            parentID: self.parentID,
            submissionID: self.submission?.id
        )

        var actionPromise: Promise<Comment>
        var moduleOutputHandler: ((Comment) -> Void)?

        if let comment = self.comment {
            currentComment.id = comment.id
            actionPromise = self.provider.update(comment: currentComment)
            moduleOutputHandler = self.moduleOutput?.handleCommentUpdated(_:)
        } else {
            actionPromise = self.provider.create(comment: currentComment)
            moduleOutputHandler = self.moduleOutput?.handleCommentCreated(_:)
        }

        actionPromise.done { comment in
            self.currentText = comment.text.replacingOccurrences(of: "<br>", with: "\n")
            self.presenter.presentCommentMainActionResult(response: .init(data: .success(self.makeCommentData())))
            moduleOutputHandler?(comment)
        }.catch { error in
            self.presenter.presentCommentMainActionResult(
                response: WriteComment.CommentMainAction.Response(data: .failure(error))
            )
        }
    }

    func doCommentCancelPresentation(request: WriteComment.CommentCancelPresentation.Request) {
        self.presenter.presentCommentCancelPresentation(
            response: .init(
                originalText: self.originalText,
                currentText: self.currentText,
                originalSubmissionID: self.originalSubmissionID,
                currentSubmissionID: self.submission?.id
            )
        )
    }

    func doSolutionPresentation(request: WriteComment.SolutionPresentation.Request) {
        self.presenter.presentSolution(response: .init(stepID: self.targetID))
    }

    func doSolutionUpdate(request: WriteComment.SolutionUpdate.Request) {
        self.submission = request.submission
        self.presenter.presentSolutionUpdate(response: .init(data: self.makeCommentData()))
    }

    // MARK: Private API

    private func makeCommentData() -> WriteComment.CommentData {
        .init(
            text: self.currentText,
            comment: self.comment,
            submission: self.submission,
            discussionThreadType: self.discussionThreadType
        )
    }
}
