import Foundation
import PromiseKit

protocol CourseListsNetworkServiceProtocol: AnyObject {
    func fetch(id: CourseListModel.IdType, page: Int) -> Promise<([CourseListModel], Meta)>
    func fetch(language: ContentLanguage, page: Int) -> Promise<([CourseListModel], Meta)>
}

extension CourseListsNetworkServiceProtocol {
    func fetch(id: CourseListModel.IdType) -> Promise<([CourseListModel], Meta)> {
        self.fetch(id: id, page: 1)
    }

    func fetch(language: ContentLanguage) -> Promise<([CourseListModel], Meta)> {
        self.fetch(language: language, page: 1)
    }
}

final class CourseListsNetworkService: CourseListsNetworkServiceProtocol {
    private let courseListsAPI: CourseListsAPI

    init(courseListsAPI: CourseListsAPI) {
        self.courseListsAPI = courseListsAPI
    }

    func fetch(id: CourseListModel.IdType, page: Int) -> Promise<([CourseListModel], Meta)> {
        Promise { seal in
            self.courseListsAPI.retrieve(id: id, page: page).done { courseLists, meta in
                seal.fulfill((courseLists, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(language: ContentLanguage, page: Int) -> Promise<([CourseListModel], Meta)> {
        Promise { seal in
            self.courseListsAPI.retrieve(language: language, page: page).done { courseLists, meta in
                seal.fulfill((courseLists, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
