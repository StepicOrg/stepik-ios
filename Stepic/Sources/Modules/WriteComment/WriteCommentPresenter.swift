import UIKit

protocol WriteCommentPresenterProtocol {
    func presentNavigationItemUpdate(response: WriteComment.NavigationItemUpdate.Response)
    func presentComment(response: WriteComment.CommentLoad.Response)
    func presentCommentTextUpdate(response: WriteComment.CommentTextUpdate.Response)
    func presentCommentMainActionResult(response: WriteComment.CommentMainAction.Response)
    func presentCommentCancelPresentation(response: WriteComment.CommentCancelPresentation.Response)
}

final class WriteCommentPresenter: WriteCommentPresenterProtocol {
    weak var viewController: WriteCommentViewControllerProtocol?

    // MARK: Protocol Conforming

    func presentNavigationItemUpdate(response: WriteComment.NavigationItemUpdate.Response) {
        let title: String = {
            switch response.discussionThreadType {
            case .default:
                return NSLocalizedString("WriteCommentDefaultTitle", comment: "")
            case .solutions:
                return NSLocalizedString("WriteCommentSolutionTitle", comment: "")
            }
        }()
        self.viewController?.displayNavigationItemUpdate(viewModel: .init(title: title))
    }

    func presentComment(response: WriteComment.CommentLoad.Response) {
        let viewModel = self.makeViewModel(
            text: response.data.text,
            presentationContext: response.data.presentationContext
        )
        self.viewController?.displayComment(viewModel: .init(state: .result(data: viewModel)))
    }

    func presentCommentTextUpdate(response: WriteComment.CommentTextUpdate.Response) {
        let viewModel = self.makeViewModel(
            text: response.data.text,
            presentationContext: response.data.presentationContext
        )
        self.viewController?.displayCommentTextUpdate(viewModel: .init(state: .result(data: viewModel)))
    }

    func presentCommentMainActionResult(response: WriteComment.CommentMainAction.Response) {
        switch response.data {
        case .success(let data):
            let viewModel = self.makeViewModel(
                text: data.text,
                presentationContext: data.presentationContext
            )
            self.viewController?.displayCommentMainActionResult(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCommentMainActionResult(viewModel: .init(state: .error))
        }
    }

    func presentCommentCancelPresentation(response: WriteComment.CommentCancelPresentation.Response) {
        let hasChanges = response.originalText != response.currentText && !response.currentText.isEmpty
        self.viewController?.displayCommentCancelPresentation(viewModel: .init(shouldAskUser: hasChanges))
    }

    // MARK: Private API

    private func makeViewModel(
        text: String,
        presentationContext: WriteComment.PresentationContext
    ) -> WriteCommentViewModel {
        let title: String = {
            switch presentationContext {
            case .create:
                return NSLocalizedString("WriteCommentActionButtonCreate", comment: "")
            case .edit:
                return NSLocalizedString("WriteCommentActionButtonEdit", comment: "")
            }
        }()

        return .init(text: text, doneButtonTitle: title, isFilled: !text.isEmpty)
    }
}
