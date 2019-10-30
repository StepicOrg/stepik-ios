import UIKit

protocol WriteCommentPresenterProtocol {
    func presentComment(response: WriteComment.CommentLoad.Response)
    func presentCommentTextUpdate(response: WriteComment.CommentTextUpdate.Response)
    func presentCommentMainActionResult(response: WriteComment.CommentMainAction.Response)
    func presentCommentCancelPresentation(response: WriteComment.CommentCancelPresentation.Response)
}

final class WriteCommentPresenter: WriteCommentPresenterProtocol {
    weak var viewController: WriteCommentViewControllerProtocol?

    func presentComment(response: WriteComment.CommentLoad.Response) {
        let viewModel = self.makeViewModel(
            text: response.data.text,
            presentationContext: response.data.presentationContext
        )
        self.viewController?.displayComment(
            viewModel: WriteComment.CommentLoad.ViewModel(state: .result(data: viewModel))
        )
    }

    func presentCommentTextUpdate(response: WriteComment.CommentTextUpdate.Response) {
        let viewModel = self.makeViewModel(
            text: response.data.text,
            presentationContext: response.data.presentationContext
        )
        self.viewController?.displayCommentTextUpdate(
            viewModel: WriteComment.CommentTextUpdate.ViewModel(state: .result(data: viewModel))
        )
    }

    func presentCommentMainActionResult(response: WriteComment.CommentMainAction.Response) {
        switch response.data {
        case .success(let data):
            let viewModel = self.makeViewModel(
                text: data.text,
                presentationContext: data.presentationContext
            )
            self.viewController?.displayCommentMainActionResult(
                viewModel: WriteComment.CommentMainAction.ViewModel(state: .result(data: viewModel))
            )
        case .failure:
            self.viewController?.displayCommentMainActionResult(
                viewModel: WriteComment.CommentMainAction.ViewModel(state: .error)
            )
        }
    }

    func presentCommentCancelPresentation(response: WriteComment.CommentCancelPresentation.Response) {
        self.viewController?.displayCommentCancelPresentation(
            viewModel: WriteComment.CommentCancelPresentation.ViewModel(
                shouldAskUser: response.originalText != response.currentText && !response.currentText.isEmpty
            )
        )
    }

    // MARK: - Private API

    private func makeViewModel(
        text: String,
        presentationContext: WriteComment.PresentationContext
    ) -> WriteCommentViewModel {
        var buttonTitle: String

        switch presentationContext {
        case .create:
            buttonTitle = NSLocalizedString("WriteCommentActionButtonCreate", comment: "")
        case .edit:
            buttonTitle = NSLocalizedString("WriteCommentActionButtonEdit", comment: "")
        }

        return WriteCommentViewModel(
            text: text,
            doneButtonTitle: buttonTitle,
            isFilled: !text.isEmpty
        )
    }
}
