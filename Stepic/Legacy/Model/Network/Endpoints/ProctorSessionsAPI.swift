import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ProctorSessionsAPI: APIEndpoint {
    override class var name: String { "proctor-sessions" }

    func get(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]> {
        ProctorSession.fetchAsync(ids: ids).then { cachedProctorSessions in
            self.retrieve.request(
                requestEndpoint: Self.name,
                paramName: Self.name,
                ids: ids,
                updating: cachedProctorSessions,
                withManager: self.manager
            )
        }
    }
}
