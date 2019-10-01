import Foundation
import PromiseKit

protocol WriteCourseReviewInteractorProtocol {
    func doReviewUpdate(request: WriteCourseReview.ReviewUpdate.Request)
    func doRatingUpdate(request: WriteCourseReview.RatingUpdate.Request)
}

final class WriteCourseReviewInteractor: WriteCourseReviewInteractorProtocol {
    weak var moduleOutput: WriteCourseReviewOutputProtocol?

    private let presenter: WriteCourseReviewPresenterProtocol
    private let provider: WriteCourseReviewProviderProtocol

    private var currentReview: String?
    private var currentRating: Int?

    init(
        presenter: WriteCourseReviewPresenterProtocol,
        provider: WriteCourseReviewProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doReviewUpdate(request: WriteCourseReview.ReviewUpdate.Request) {
        self.currentReview = request.review

        self.presenter.presentReviewUpdate(
            response: WriteCourseReview.ReviewUpdate.Response(
                result: WriteCourseReview.CourseReviewInfo(
                    review: self.currentReview,
                    rating: self.currentRating
                )
            )
        )
    }

    func doRatingUpdate(request: WriteCourseReview.RatingUpdate.Request) {
        self.currentRating = request.rating

        self.presenter.presentRatingUpdate(
            response: WriteCourseReview.RatingUpdate.Response(
                result: WriteCourseReview.CourseReviewInfo(
                    review: self.currentReview,
                    rating: self.currentRating
                )
            )
        )
    }
}
