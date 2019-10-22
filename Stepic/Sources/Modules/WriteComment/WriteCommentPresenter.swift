import UIKit

protocol WriteCommentPresenterProtocol {
    func presentComment(response: WriteComment.CommentLoad.Response)
    func presentCommentTextUpdate(response: WriteComment.CommentTextUpdate.Response)
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

    // MARK: - Private API

    private func makeViewModel(
        text: String,
        presentationContext: WriteComment.PresentationContext
    ) -> WriteCommentViewModel {
        let buttonTitle = presentationContext == .create
            ? NSLocalizedString("WriteCommentActionButtonCreate", comment: "")
            : NSLocalizedString("WriteCommentActionButtonEdit", comment: "")
        return WriteCommentViewModel(
            text: text,
            doneButtonTitle: buttonTitle,
            isFilled: !text.isEmpty
        )
    }
}
