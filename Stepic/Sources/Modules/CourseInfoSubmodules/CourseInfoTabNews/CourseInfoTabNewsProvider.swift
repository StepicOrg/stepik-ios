import Foundation
import PromiseKit

protocol CourseInfoTabNewsProviderProtocol {
    func fetchCached(courseID: Course.IdType) -> Promise<([AnnouncementPlainObject], Meta)>
    func fetchRemote(courseID: Course.IdType, page: Int) -> Promise<([AnnouncementPlainObject], Meta)>
}

final class CourseInfoTabNewsProvider: CourseInfoTabNewsProviderProtocol {
    private let announcementsRepository: AnnouncementsRepositoryProtocol

    init(announcementsRepository: AnnouncementsRepositoryProtocol) {
        self.announcementsRepository = announcementsRepository
    }

    func fetchCached(courseID: Course.IdType) -> Promise<([AnnouncementPlainObject], Meta)> {
        Promise { seal in
            self.announcementsRepository.fetch(courseID: courseID, dataSourceType: .cache).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote(courseID: Course.IdType, page: Int) -> Promise<([AnnouncementPlainObject], Meta)> {
        Promise { seal in
            self.announcementsRepository.fetch(courseID: courseID, page: page, dataSourceType: .remote).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
