import Foundation
import PromiseKit

protocol CoursesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Course.IdType], page: Int) -> Promise<([Course], Meta)>
    func fetch(id: Course.IdType) -> Promise<Course?>
    func fetchEnrolled() -> Guarantee<[Course]>
    func fetchAll() -> Guarantee<[Course]>
}

final class CoursesPersistenceService: CoursesPersistenceServiceProtocol {
    func fetch(ids: [Course.IdType], page: Int = 1) -> Promise<([Course], Meta)> {
        Promise { seal in
            Course.fetchAsync(ids: ids).done { courses in
                seal.fulfill((courses, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Course.IdType) -> Promise<Course?> {
        Promise { seal in
            self.fetch(ids: [id]).done { courses, _ in
                seal.fulfill(courses.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchEnrolled() -> Guarantee<[Course]> {
        Guarantee { seal in
            let enrolledCourses = Course.getAllCourses(enrolled: true)
            seal(enrolledCourses)
        }
    }

    func fetchAll() -> Guarantee<[Course]> {
        Guarantee { seal in
            let allCourses = Course.getAllCourses()
            seal(allCourses)
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
