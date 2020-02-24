import UIKit

protocol WriteCommentPresenterProtocol {
    func presentNavigationItemUpdate(response: WriteComment.NavigationItemUpdate.Response)
    func presentComment(response: WriteComment.CommentLoad.Response)
    func presentCommentTextUpdate(response: WriteComment.CommentTextUpdate.Response)
    func presentCommentMainActionResult(response: WriteComment.CommentMainAction.Response)
    func presentCommentCancelPresentation(response: WriteComment.CommentCancelPresentation.Response)
    func presentSolution(response: WriteComment.SolutionPresentation.Response)
    func presentSelectSolution(response: WriteComment.SelectSolution.Response)
    func presentSolutionUpdate(response: WriteComment.SolutionUpdate.Response)
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
        let viewModel = self.makeViewModel(response.data)
        self.viewController?.displayComment(viewModel: .init(state: .result(data: viewModel)))
    }

    func presentCommentTextUpdate(response: WriteComment.CommentTextUpdate.Response) {
        let viewModel = self.makeViewModel(response.data)
        self.viewController?.displayCommentTextUpdate(viewModel: .init(state: .result(data: viewModel)))
    }

    func presentCommentMainActionResult(response: WriteComment.CommentMainAction.Response) {
        switch response.data {
        case .success(let data):
            let viewModel = self.makeViewModel(data)
            self.viewController?.displayCommentMainActionResult(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCommentMainActionResult(viewModel: .init(state: .error))
        }
    }

    func presentCommentCancelPresentation(response: WriteComment.CommentCancelPresentation.Response) {
        let hasTextChanges = response.originalText != response.currentText && !response.currentText.isEmpty
        let hasSubmissionChanges = response.originalSubmissionID != response.currentSubmissionID
        let hasChanges = hasTextChanges || hasSubmissionChanges
        self.viewController?.displayCommentCancelPresentation(viewModel: .init(shouldAskUser: hasChanges))
    }

    func presentSolution(response: WriteComment.SolutionPresentation.Response) {
        self.viewController?.displaySolution(
            viewModel: .init(
                stepID: response.stepID,
                submission: response.submission,
                discussionID: response.discussionID
            )
        )
    }

    func presentSelectSolution(response: WriteComment.SelectSolution.Response) {
        self.viewController?.displaySelectSolution(viewModel: .init(stepID: response.stepID))
    }

    func presentSolutionUpdate(response: WriteComment.SolutionUpdate.Response) {
        let viewModel = self.makeViewModel(response.data)
        self.viewController?.displaySolutionUpdate(viewModel: .init(state: .result(data: viewModel)))
    }

    // MARK: Private API

    private func makeViewModel(_ data: WriteComment.CommentData) -> WriteCommentViewModel {
        let doneButtonTitle = data.comment == nil
            ? NSLocalizedString("WriteCommentActionButtonCreate", comment: "")
            : NSLocalizedString("WriteCommentActionButtonEdit", comment: "")

        let solutionTitle: String = {
            if let submission = data.submission {
                return String(
                    format: NSLocalizedString("WriteCommentSolutionFormatTitle", comment: ""),
                    arguments: ["\(submission.id)"]
                )
            }
            return NSLocalizedString("WriteCommentSelectSolutionTitle", comment: "")
        }()

        let isReply = data.parentID != nil

        let isFilled: Bool = {
            if !isReply && data.discussionThreadType == .solutions {
                return !data.text.isEmpty && data.submission != nil
            }
            return !data.text.isEmpty
        }()

        let isSolutionHidden = isReply || data.discussionThreadType != .solutions

        return .init(
            text: data.text,
            doneButtonTitle: doneButtonTitle,
            isFilled: isFilled,
            isSolutionHidden: isSolutionHidden,
            isSolutionSelected: data.submission != nil,
            isSolutionCorrect: data.submission?.isCorrect ?? false,
            solutionTitle: solutionTitle
        )
    }
}
