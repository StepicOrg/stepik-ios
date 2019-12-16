import UIKit

protocol WriteCourseReviewPresenterProtocol {
    func presentCourseReview(response: WriteCourseReview.CourseReviewLoad.Response)
    func presentCourseReviewTextUpdate(response: WriteCourseReview.CourseReviewTextUpdate.Response)
    func presentCourseReviewScoreUpdate(response: WriteCourseReview.CourseReviewScoreUpdate.Response)
    func presentCourseReviewMainActionResult(response: WriteCourseReview.CourseReviewMainAction.Response)

    func presentWaitingState(response: WriteCourseReview.BlockingWaitingIndicatorUpdate.Response)
}

final class WriteCourseReviewPresenter: WriteCourseReviewPresenterProtocol {
    weak var viewController: WriteCourseReviewViewControllerProtocol?

    func presentCourseReview(response: WriteCourseReview.CourseReviewLoad.Response) {
        self.viewController?.displayCourseReview(
            viewModel: WriteCourseReview.CourseReviewLoad.ViewModel(
                viewModel: self.makeViewModel(info: response.result)
            )
        )
    }

    func presentCourseReviewTextUpdate(response: WriteCourseReview.CourseReviewTextUpdate.Response) {
        self.viewController?.displayCourseReviewTextUpdate(
            viewModel: WriteCourseReview.CourseReviewTextUpdate.ViewModel(
                viewModel: self.makeViewModel(info: response.result)
            )
        )
    }

    func presentCourseReviewScoreUpdate(response: WriteCourseReview.CourseReviewScoreUpdate.Response) {
        self.viewController?.displayCourseReviewScoreUpdate(
            viewModel: WriteCourseReview.CourseReviewScoreUpdate.ViewModel(
                viewModel: self.makeViewModel(info: response.result)
            )
        )
    }

    func presentCourseReviewMainActionResult(response: WriteCourseReview.CourseReviewMainAction.Response) {
        self.viewController?.displayCourseReviewMainActionResult(
            viewModel: WriteCourseReview.CourseReviewMainAction.ViewModel(
                isSuccessful: response.isSuccessful,
                message: response.isSuccessful
                    ? NSLocalizedString("WriteCourseReviewActionSendResultSuccess", comment: "")
                    : NSLocalizedString("WriteCourseReviewActionSendResultFailed", comment: "")
            )
        )
    }

    func presentWaitingState(response: WriteCourseReview.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(
            viewModel: WriteCourseReview.BlockingWaitingIndicatorUpdate.ViewModel(
                shouldDismiss: response.shouldDismiss
            )
        )
    }

    // MARK: - Private API

    private func makeViewModel(info: WriteCourseReview.CourseReviewInfo) -> WriteCourseReviewViewModel {
        WriteCourseReviewViewModel(
            text: info.text,
            score: info.score,
            isFilled: !info.text.isEmpty && info.score > 0
        )
    }
}
