import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ExamSessionsAPI: APIEndpoint {
    override class var name: String { "exam-sessions" }

    func get(ids: [ExamSession.IdType]) -> Promise<[ExamSession]> {
        ExamSession.fetchAsync(ids: ids).then { cachedExamSessions in
            self.retrieve.request(
                requestEndpoint: Self.name,
                paramName: Self.name,
                ids: ids,
                updating: cachedExamSessions,
                withManager: self.manager
            )
        }
    }
}
