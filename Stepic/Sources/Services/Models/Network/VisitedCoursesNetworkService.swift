import Foundation
import PromiseKit

protocol VisitedCoursesNetworkServiceProtocol: AnyObject {
    func fetch(page: Int) -> Promise<([VisitedCourse], Meta)>
}

extension VisitedCoursesNetworkServiceProtocol {
    func fetch() -> Promise<([VisitedCourse], Meta)> {
        self.fetch(page: 1)
    }
}

final class VisitedCoursesNetworkService: VisitedCoursesNetworkServiceProtocol {
    private let visitedCoursesAPI: VisitedCoursesAPI

    init(visitedCoursesAPI: VisitedCoursesAPI) {
        self.visitedCoursesAPI = visitedCoursesAPI
    }

    func fetch(page: Int) -> Promise<([VisitedCourse], Meta)> {
        Promise { seal in
            self.visitedCoursesAPI.retrieve(page: page).done { visitedCourses, meta in
                seal.fulfill((visitedCourses, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
