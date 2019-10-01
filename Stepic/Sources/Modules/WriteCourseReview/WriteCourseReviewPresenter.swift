import UIKit

protocol WriteCourseReviewPresenterProtocol {
    func presentReviewUpdate(response: WriteCourseReview.ReviewUpdate.Response)
    func presentRatingUpdate(response: WriteCourseReview.RatingUpdate.Response)
}

final class WriteCourseReviewPresenter: WriteCourseReviewPresenterProtocol {
    weak var viewController: WriteCourseReviewViewControllerProtocol?

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
