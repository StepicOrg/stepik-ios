import CoreData
import Foundation
import PromiseKit

protocol CoursesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Course.IdType]) -> Promise<[Course]>
    func fetch(id: Course.IdType) -> Promise<Course?>
    func fetchEnrolled() -> Guarantee<[Course]>
    func fetchAll() -> Guarantee<[Course]>
    func unenrollAll() -> Promise<Void>
}

extension CoursesPersistenceServiceProtocol {
    func fetch(ids: [Course.IdType], page: Int = 1) -> Promise<([Course], Meta)> {
        self.fetch(ids: ids).map { ($0, Meta.oneAndOnlyPage) }
    }
}

final class CoursesPersistenceService: CoursesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Course.IdType]) -> Promise<[Course]> {
        Promise { seal in
            Course.fetchAsync(ids: ids).done { courses in
                seal.fulfill(courses)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Course.IdType) -> Promise<Course?> {
        Promise { seal in
            self.fetch(ids: [id]).done { courses in
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

    func unenrollAll() -> Promise<Void> {
        Promise { seal in
            let batchUpdateRequest = NSBatchUpdateRequest(entityName: "Course")
            batchUpdateRequest.predicate = NSPredicate(format: "managedEnrolled == %@", NSNumber(value: true))
            batchUpdateRequest.propertiesToUpdate = ["managedEnrolled": NSNumber(value: false)]

            self.managedObjectContext.performAndWait {
                do {
                    try self.managedObjectContext.executeAndMergeChanges(using: batchUpdateRequest)
                    try self.managedObjectContext.save()
                    seal.fulfill(())
                } catch {
                    seal.reject(Error.batchUpdateFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case batchUpdateFailed
    }
}
