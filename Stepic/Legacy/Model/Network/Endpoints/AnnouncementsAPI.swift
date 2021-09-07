import Alamofire
import Foundation
import PromiseKit

final class AnnouncementsAPI: APIEndpoint {
    override var name: String { "announcements" }

    func retrieve(courseID: Course.IdType, page: Int = 1) -> Promise<([AnnouncementPlainObject], Meta)> {
        let params: Parameters = [
            "course": courseID,
            "page": page
        ]

        return self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            params: params,
            withManager: self.manager
        )
    }
}
