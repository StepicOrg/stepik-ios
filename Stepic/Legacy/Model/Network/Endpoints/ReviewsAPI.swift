import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ReviewsAPI: APIEndpoint {
    override var name: String { "reviews" }

    func getReviews(ids: [Int], blockName: String?) -> Promise<ReviewsResponse> {
        self.retrieve
            .request(requestEndpoint: self.name, ids: ids, withManager: self.manager)
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
            .request(requestEndpoint: self.name, params: params, withManager: self.manager)
            .map { ReviewSessionResponse(json: $0, blockName: blockName ?? "") }
    }

    private enum JSONKey: String {
        case user
        case instruction
    }
}