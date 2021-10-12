import Foundation
import PromiseKit

protocol CourseInfoPurchaseModalProviderProtocol {
    func fetchCourseFromCache() -> Promise<Course?>
    func fetchCourseFromRemote() -> Promise<Course?>
    func fetchCourseFromCacheOrRemote() -> Promise<Course?>
}

final class CourseInfoPurchaseModalProvider: CourseInfoPurchaseModalProviderProtocol {
    private let courseID: Course.IdType

    private let coursesRepository: CoursesRepositoryProtocol

    init(
        courseID: Course.IdType,
        coursesRepository: CoursesRepositoryProtocol
    ) {
        self.courseID = courseID
        self.coursesRepository = coursesRepository
    }

    func fetchCourseFromCache() -> Promise<Course?> {
        Promise { seal in
            self.coursesRepository.fetch(id: self.courseID, dataSourceType: .cache).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchCourseFromRemote() -> Promise<Course?> {
        Promise { seal in
            self.coursesRepository.fetch(id: self.courseID, dataSourceType: .remote).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCourseFromCacheOrRemote() -> Promise<Course?> {
        Promise { seal in
            self.coursesRepository.fetch(id: self.courseID, fetchPolicy: .cacheFirst).done { course in
                seal.fulfill(course)
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
