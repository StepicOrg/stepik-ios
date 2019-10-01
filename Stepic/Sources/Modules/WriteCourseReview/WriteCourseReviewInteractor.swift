import Foundation
import PromiseKit

protocol WriteCourseReviewInteractorProtocol {
    func doSendReview(request: WriteCourseReview.SendReview.Request)
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

    func doSendReview(request: WriteCourseReview.SendReview.Request) {
        guard let review = self.currentReview?.trimmingCharacters(in: .whitespacesAndNewlines),
              let rating = self.currentRating else {
            return
        }

        print("review: \(review)\nrating: \(rating)")

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.presenter.presentSendReviewResult(
                response: WriteCourseReview.SendReview.Response(
                    isSuccessful: false
                )
            )
        }
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
