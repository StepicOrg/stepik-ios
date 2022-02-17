import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ReviewSessionsAPI: APIEndpoint {
    override class var name: String { "review-sessions" }

    func createReviewSession(submissionID: Submission.IdType, blockName: String?) -> Promise<ReviewSessionResponse> {
        let body = [
            JSONKey.reviewSession.rawValue: [
                JSONKey.submission.rawValue: submissionID
            ]
        ]

        return self.create
            .request(requestEndpoint: Self.name, bodyJSONObject: body, withManager: self.manager)
            .map { ReviewSessionResponse(json: $0, blockName: blockName ?? "") }
    }

    func createReviewSession(instructionID: Int, blockName: String?) -> Promise<ReviewSessionResponse> {
        let body = [
            JSONKey.reviewSession.rawValue: [
                JSONKey.instruction.rawValue: instructionID
            ]
        ]

        return self.create
            .request(requestEndpoint: Self.name, bodyJSONObject: body, withManager: self.manager)
            .map { ReviewSessionResponse(json: $0, blockName: blockName ?? "") }
    }

    /// Get review sessions by ids.
    ///
    /// - Parameter ids: The identifiers array of the review sessions to fetch.
    /// - Parameter blockName: The name of the step's block (see Block.BlockType) for parsing reply and dataset.
    /// - Returns: A promise with an `ReviewSessionResponse`.
    func getReviewSessions(ids: [Int], blockName: String?) -> Promise<ReviewSessionResponse> {
        self.retrieve
            .request(requestEndpoint: Self.name, ids: ids, withManager: self.manager)
            .map { ReviewSessionResponse(json: $0, blockName: blockName ?? "") }
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
        case reviewSession
        case submission
    }
}
