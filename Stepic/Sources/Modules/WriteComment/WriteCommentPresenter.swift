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
