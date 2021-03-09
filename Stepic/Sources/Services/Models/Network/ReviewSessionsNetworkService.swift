import Foundation
import PromiseKit

protocol ReviewSessionsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Int], blockName: String?) -> Promise<[ReviewSessionDataPlainObject]>
}

final class ReviewSessionsNetworkService: ReviewSessionsNetworkServiceProtocol {
    private let reviewSessionsAPI: ReviewSessionsAPI

    init(reviewSessionsAPI: ReviewSessionsAPI) {
        self.reviewSessionsAPI = reviewSessionsAPI
    }

    func fetch(ids: [Int], blockName: String?) -> Promise<[ReviewSessionDataPlainObject]> {
        self.reviewSessionsAPI
            .getReviewSessions(ids: ids, blockName: blockName)
            .map(self.mapReviewSessionResponseToData)
    }

    private func mapReviewSessionResponseToData(_ response: ReviewSessionResponse) -> [ReviewSessionDataPlainObject] {
        let attemptsMap = response.attempts.reduce(into: [:]) { $0[$1.id] = $1 }
        let submissionsMap = response.submissions.reduce(into: [:]) { $0[$1.id] = $1 }
        let reviewsMap = response.reviews.reduce(into: [:]) { $0[$1.id] = $1 }
        let rubricScoresMap = response.rubricScores.reduce(into: [:]) { $0[$1.id] = $1 }

        return response.reviewSessions.compactMap { session -> ReviewSessionDataPlainObject? in
            guard let submission = submissionsMap[session.submission],
                  let attempt = attemptsMap[submission.attemptID] else {
                return nil
            }

            submission.attempt = attempt

            func mapReviews(_ ids: [Int]) -> [ReviewDataPlainObject] {
                ids.compactMap { id -> ReviewDataPlainObject? in
                    if let review = reviewsMap[id] {
                        let rubricScores = review.rubricScores.compactMap { rubricScoresMap[$0] }
                        return ReviewDataPlainObject(review: review, rubricScores: rubricScores)
                    }
                    return nil
                }
            }

            let givenReviews = mapReviews(session.givenReviews)
            let takenReviews = mapReviews(session.takenReviews)

            return ReviewSessionDataPlainObject(
                reviewSession: session,
                submission: submission,
                attempt: attempt,
                givenReviews: givenReviews,
                takenReviews: takenReviews
            )
        }
    }
}
