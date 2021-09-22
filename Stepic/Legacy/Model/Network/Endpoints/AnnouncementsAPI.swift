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

    func retrieve(ids: [Announcement.IdType]) -> Promise<([AnnouncementPlainObject], Meta)> {
        self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            ids: ids,
            updating: [],
            withManager: self.manager
        ).map { ($0, Meta.oneAndOnlyPage) }
    }
}
