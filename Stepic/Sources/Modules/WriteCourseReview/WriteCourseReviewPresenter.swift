import UIKit

protocol WriteCourseReviewPresenterProtocol {
    func presentSendReviewResult(response: WriteCourseReview.SendReview.Response)
    func presentReviewUpdate(response: WriteCourseReview.ReviewUpdate.Response)
    func presentRatingUpdate(response: WriteCourseReview.RatingUpdate.Response)
    func presentWaitingState(response: WriteCourseReview.BlockingWaitingIndicatorUpdate.Response)
}

final class WriteCourseReviewPresenter: WriteCourseReviewPresenterProtocol {
    weak var viewController: WriteCourseReviewViewControllerProtocol?

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
        let viewModel = self.makeViewModel(info: response.result)
        self.viewController?.displayReviewUpdate(
            viewModel: WriteCourseReview.ReviewUpdate.ViewModel(
                viewModel: viewModel
            )
        )
    }

    func presentRatingUpdate(response: WriteCourseReview.RatingUpdate.Response) {
        let viewModel = self.makeViewModel(info: response.result)
        self.viewController?.displayRatingUpdate(
            viewModel: WriteCourseReview.RatingUpdate.ViewModel(
                viewModel: viewModel
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
