import Foundation
import PromiseKit

protocol ReviewsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Int], blockName: String?) -> Promise<[ReviewDataPlainObject]>
}

final class ReviewsNetworkService: ReviewsNetworkServiceProtocol {
    private let reviewsAPI: ReviewsAPI

    init(reviewsAPI: ReviewsAPI) {
        self.reviewsAPI = reviewsAPI
    }

    func fetch(ids: [Int], blockName: String?) -> Promise<[ReviewDataPlainObject]> {
        self.reviewsAPI
            .getReviews(ids: ids, blockName: blockName)
            .map(self.mapReviewsResponseToData)
    }

    private func mapReviewsResponseToData(_ response: ReviewsResponse) -> [ReviewDataPlainObject] {
        let attemptsMap = response.attempts.reduce(into: [:]) { $0[$1.id] = $1 }
        let submissionsMap = response.submissions.reduce(into: [:]) { $0[$1.id] = $1 }
        let rubricScoresMap = response.rubricScores.reduce(into: [:]) { $0[$1.id] = $1 }

        for (_, submission) in submissionsMap {
            submission.attempt = attemptsMap[submission.attemptID]
        }

        return response.reviews.map { review -> ReviewDataPlainObject in
            let rubricScores = review.rubricScores.compactMap { rubricScoresMap[$0] }
            let submission = review.submission != nil ? submissionsMap[review.submission.require()] : nil

            return ReviewDataPlainObject(
                review: review,
                rubricScores: rubricScores,
                submission: submission
            )
        }
    }
}
