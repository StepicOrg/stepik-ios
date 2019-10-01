import UIKit

protocol WriteCourseReviewPresenterProtocol {
    func presentCourseReview(response: WriteCourseReview.CourseReviewLoad.Response)
    func presentSendReviewResult(response: WriteCourseReview.SendReview.Response)
    func presentReviewUpdate(response: WriteCourseReview.ReviewUpdate.Response)
    func presentRatingUpdate(response: WriteCourseReview.RatingUpdate.Response)
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

    func presentSendReviewResult(response: WriteCourseReview.SendReview.Response) {
        self.viewController?.displaySendReviewResult(
            viewModel: WriteCourseReview.SendReview.ViewModel(
                isSuccessful: response.isSuccessful,
                message: response.isSuccessful
                    ? NSLocalizedString("WriteCourseReviewActionSendResultSuccess", comment: "")
                    : NSLocalizedString("WriteCourseReviewActionSendResultFailed", comment: "")
            )
        )
    }

    func presentReviewUpdate(response: WriteCourseReview.ReviewUpdate.Response) {
        self.viewController?.displayReviewUpdate(
            viewModel: WriteCourseReview.ReviewUpdate.ViewModel(
                viewModel: self.makeViewModel(info: response.result)
            )
        )
    }

    func presentRatingUpdate(response: WriteCourseReview.RatingUpdate.Response) {
        self.viewController?.displayRatingUpdate(
            viewModel: WriteCourseReview.RatingUpdate.ViewModel(
                viewModel: self.makeViewModel(info: response.result)
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

    private func makeViewModel(info: WriteCourseReview.CourseReviewInfo) -> WriteCourseReviewViewModel {
        let review = info.review ?? ""
        let rating = info.rating ?? 0

        return WriteCourseReviewViewModel(
            review: review,
            rating: rating,
            isFilled: !review.isEmpty && rating > 0
        )
    }
}
