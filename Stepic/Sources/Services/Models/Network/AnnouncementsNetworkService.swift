import Foundation
import PromiseKit

protocol AnnouncementsNetworkServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType, page: Int) -> Promise<([AnnouncementPlainObject], Meta)>
}

extension AnnouncementsNetworkServiceProtocol {
    func fetch(courseID: Course.IdType) -> Promise<([AnnouncementPlainObject], Meta)> {
        self.fetch(courseID: courseID, page: 1)
    }
}

final class AnnouncementsNetworkService: AnnouncementsNetworkServiceProtocol {
    private let announcementsAPI: AnnouncementsAPI

    init(announcementsAPI: AnnouncementsAPI) {
        self.announcementsAPI = announcementsAPI
    }

    func fetch(courseID: Course.IdType, page: Int) -> Promise<([AnnouncementPlainObject], Meta)> {
        self.announcementsAPI.retrieve(courseID: courseID, page: page)
    }
}
