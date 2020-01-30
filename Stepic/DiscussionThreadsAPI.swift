import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class DiscussionThreadsAPI: APIEndpoint {
    override var name: String { "discussion-threads" }

    /// Get discussion threads by ids.
    func retrieve(ids: [DiscussionThread.IdType], page: Int = 1) -> Promise<([DiscussionThread], Meta)> {
        Promise { seal in
            let params: Parameters = [
                "ids": ids,
                "page": page
            ]

            firstly {
                DiscussionThread.fetchAsync(ids: ids)
            }.then { cachedDiscussionThreads -> Promise<([DiscussionThread], Meta, JSON)> in
                self.retrieve.request(
                    requestEndpoint: self.name,
                    paramName: self.name,
                    params: params,
                    withManager: self.manager
                )
            }.done { discussionThreads, meta, _ in
                seal.fulfill((discussionThreads, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
