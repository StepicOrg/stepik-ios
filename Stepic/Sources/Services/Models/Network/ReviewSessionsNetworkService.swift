import Foundation
import PromiseKit

protocol ReviewSessionsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Int], blockName: String?) -> Promise<[ReviewSessionDataPlainObject]>
    func fetch(userID: User.IdType, instructionID: Int, blockName: String?) -> Promise<ReviewSessionDataPlainObject?>
    func create(submissionID: Submission.IdType, blockName: String?) -> Promise<ReviewSessionDataPlainObject?>
}

extension ReviewSessionsNetworkServiceProtocol {
    func fetch(id: Int, blockName: String?) -> Promise<ReviewSessionDataPlainObject?> {
        self.fetch(ids: [id], blockName: blockName).map(\.first)
    }
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

    func fetch(userID: User.IdType, instructionID: Int, blockName: String?) -> Promise<ReviewSessionDataPlainObject?> {
        self.reviewSessionsAPI
            .getReviewSession(userID: userID, instructionID: instructionID, blockName: blockName)
            .map(self.mapReviewSessionResponseToData)
            .map(\.first)
    }

    func create(submissionID: Submission.IdType, blockName: String?) -> Promise<ReviewSessionDataPlainObject?> {
        self.reviewSessionsAPI
            .createReviewSession(submissionID: submissionID, blockName: blockName)
            .map(self.mapReviewSessionResponseToData)
            .map(\.first)
    }

    private func mapReviewSessionResponseToData(_ response: ReviewSessionResponse) -> [ReviewSessionDataPlainObject] {
        let attemptsMap = response.attempts.reduce(into: [:]) { $0[$1.id] = $1 }
        let submissionsMap = response.submissions.reduce(into: [:]) { $0[$1.id] = $1 }
        let reviewsMap = response.reviews.reduce(into: [:]) { $0[$1.id] = $1 }
        let rubricScoresMap = response.rubricScores.reduce(into: [:]) { $0[$1.id] = $1 }

        for (_, submission) in submissionsMap {
            submission.attempt = attemptsMap[submission.attemptID]
        }

        return response.reviewSessions.map { session -> ReviewSessionDataPlainObject in
            let submission = session.submission != nil ? submissionsMap[session.submission.require()] : nil

            func mapReviews(_ ids: [Int]) -> [ReviewDataPlainObject] {
                ids.compactMap { id -> ReviewDataPlainObject? in
                    if let review = reviewsMap[id] {
                        let rubricScores = review.rubricScores.compactMap { rubricScoresMap[$0] }
                        return ReviewDataPlainObject(
                            review: review,
                            rubricScores: rubricScores,
                            submission: review.submission != nil ? submissionsMap[review.submission.require()] : nil
                        )
                    }
                    return nil
                }
            }

            let givenReviews = mapReviews(session.givenReviews)
            let takenReviews = mapReviews(session.takenReviews)

            return ReviewSessionDataPlainObject(
                reviewSession: session,
                submission: submission,
                attempt: submission?.attempt,
                givenReviews: givenReviews,
                takenReviews: takenReviews
            )
        }
    }
}
