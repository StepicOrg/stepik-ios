import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ReviewSessionsAPI: APIEndpoint {
    override var name: String { "review-sessions" }

    /// Get review sessions by ids.
    ///
    /// - Parameter ids: The identifiers array of the review sessions to fetch.
    /// - Parameter blockName: The name of the step's block (see Block.BlockType) for parsing reply and dataset.
    /// - Returns: A promise with an `ReviewSessionResponse`.
    func retrieve(ids: [Int], blockName: String?) -> Promise<ReviewSessionResponse> {
        self.retrieve
            .request(requestEndpoint: self.name, ids: ids, withManager: self.manager)
            .map { ReviewSessionResponse(json: $0, blockName: blockName ?? "") }
    }
}
