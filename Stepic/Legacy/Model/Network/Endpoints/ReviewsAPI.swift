import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ReviewsAPI: APIEndpoint {
    override class var name: String { "reviews" }

    func createReview(sessionID: Int, blockName: String?) -> Promise<ReviewsResponse> {
        let body = [
            JSONKey.review.rawValue: [
                JSONKey.id.rawValue: 0,
                JSONKey.session.rawValue: sessionID
            ]
        ]

        return self.create
            .request(requestEndpoint: Self.name, bodyJSONObject: body, withManager: self.manager)
            .map { ReviewsResponse(json: $0, blockName: blockName ?? "") }
    }

    func getReviews(ids: [Int], blockName: String?) -> Promise<ReviewsResponse> {
        self.retrieve
            .request(requestEndpoint: Self.name, ids: ids, withManager: self.manager)
            .map { ReviewsResponse(json: $0, blockName: blockName ?? "") }
    }

    func getReviewSession(
        userID: User.IdType,
        instructionID: Int,
        blockName: String?
    ) -> Promise<ReviewSessionResponse> {
        let params: Parameters = [
            JSONKey.user.rawValue: userID,
            JSONKey.instruction.rawValue: instructionID
        ]

        return self.retrieve
            .request(requestEndpoint: Self.name, params: params, withManager: self.manager)
            .map { ReviewSessionResponse(json: $0, blockName: blockName ?? "") }
    }

    private enum JSONKey: String {
        case user
        case instruction
        case review
        case id
        case session
    }
}
