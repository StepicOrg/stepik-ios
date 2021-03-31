import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ProctorSessionsAPI: APIEndpoint {
    override var name: String { "proctor-sessions" }

    func get(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]> {
        ProctorSession.fetchAsync(ids: ids).then { cachedProctorSessions in
            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                ids: ids,
                updating: cachedProctorSessions,
                withManager: self.manager
            )
        }
    }
}
