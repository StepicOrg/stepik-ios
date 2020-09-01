import Foundation
import PromiseKit

protocol CourseListPersistenceServiceProtocol: AnyObject {
    func fetch() -> Promise<[Course]>
    func update(newCachedList: [Course])
}

class CourseListPersistenceService: CourseListPersistenceServiceProtocol {
    let storage: CourseListPersistenceStorage

    init(storage: CourseListPersistenceStorage) {
        self.storage = storage
    }

    func fetch() -> Promise<[Course]> {
        let courseListIDs = self.storage.getCoursesList()

        return Promise { seal in
            Course.fetchAsync(courseListIDs).done { courses in
                var uniqueCourses: [Course] = []
                for course in courses {
                    if !uniqueCourses.contains(where: { $0.id == course.id }) {
                        uniqueCourses.append(course)
                    }
                }

                let courses = uniqueCourses.reordered(order: courseListIDs, transform: { $0.id })
                seal.fulfill(courses)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func update(newCachedList: [Course]) {
        let ids = newCachedList.map { $0.id }
        self.storage.update(newCachedList: ids)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

// MARK: - VisitedCourseListPersistenceServiceProtocol: CourseListPersistenceServiceProtocol -

protocol VisitedCourseListPersistenceServiceProtocol: CourseListPersistenceServiceProtocol {
    func insert(course: Course)
}

final class VisitedCourseListPersistenceService: CourseListPersistenceService {
    private lazy var orderedSet = NSMutableOrderedSet(array: self.storage.getCoursesList())

    override func update(newCachedList: [Course]) {
        self.orderedSet.removeAllObjects()
        self.orderedSet.addObjects(from: newCachedList.map(\.id))
        self.updateStorageUsingCurrentData()
    }

    private func updateStorageUsingCurrentData() {
        let ids = self.orderedSet.array as? [Course.IdType] ?? []
        self.storage.update(newCachedList: ids)
    }
}

extension VisitedCourseListPersistenceService: VisitedCourseListPersistenceServiceProtocol {
    func insert(course: Course) {
        if self.orderedSet.contains(course.id) {
            self.orderedSet.remove(course.id)
        }

        self.orderedSet.insert(course.id, at: 0)

        self.updateStorageUsingCurrentData()
    }
}
