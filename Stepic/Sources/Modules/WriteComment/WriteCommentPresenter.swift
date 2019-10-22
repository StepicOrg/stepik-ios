import UIKit

protocol WriteCommentPresenterProtocol {
    func presentComment(response: WriteComment.CommentLoad.Response)
}

final class WriteCommentPresenter: WriteCommentPresenterProtocol {
    weak var viewController: WriteCommentViewControllerProtocol?

    func presentComment(response: WriteComment.CommentLoad.Response) {
        let viewModel = self.makeViewModel(
            text: response.result.text,
            presentationContext: response.result.presentationContext
        )
        self.viewController?.displayComment(viewModel: .init(viewModel: viewModel))
    }

    private func makeViewModel(
        text: String,
        presentationContext: WriteComment.PresentationContext
    ) -> WriteCommentViewModel {
        var placeholder: String
        var mainActionButtonTitle: String

        switch presentationContext {
        case .create:
            placeholder = NSLocalizedString("WriteCommentPlaceholderCreate", comment: "")
            mainActionButtonTitle = NSLocalizedString("WriteCommentActionButtonCreate", comment: "")
        case .edit:
            placeholder = NSLocalizedString("WriteCommentPlaceholderEdit", comment: "")
            mainActionButtonTitle = NSLocalizedString("WriteCommentActionButtonEdit", comment: "")
        }

        return WriteCommentViewModel(
            text: text,
            placeholder: placeholder,
            mainActionButtonTitle: mainActionButtonTitle,
            isFilled: !text.isEmpty
        )
    }
}
