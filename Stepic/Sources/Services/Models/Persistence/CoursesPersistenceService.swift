import CoreData
import PromiseKit

protocol CoursesPersistenceServiceProtocol: AnyObject {
    func fetch(id: Course.IdType) -> Promise<Course?>
    func fetch(ids: [Course.IdType]) -> Promise<[Course]>
    func fetchEnrolled() -> Guarantee<[Course]>
    func fetchAll() -> Guarantee<[Course]>
    func unenrollAll() -> Promise<Void>
    func batchUpdateIsInWishlist(id: Course.IdType, isInWishList: Bool) -> Promise<Void>
}

extension CoursesPersistenceServiceProtocol {
    func fetch(ids: [Course.IdType], page: Int = 1) -> Promise<([Course], Meta)> {
        self.fetch(ids: ids).map { ($0, Meta.oneAndOnlyPage) }
    }
}

final class CoursesPersistenceService: BasePersistenceService<Course>, CoursesPersistenceServiceProtocol {
    func fetch(id: Course.IdType) -> Promise<Course?> {
        firstly { () -> Guarantee<Course?> in
            self.fetch(id: id)
        }
    }

    func fetch(ids: [Course.IdType]) -> Promise<[Course]> {
        firstly { () -> Guarantee<[Course]> in
            self.fetch(ids: ids)
        }
    }

    func fetchEnrolled() -> Guarantee<[Course]> {
        Guarantee { seal in
            let enrolledCourses = Course.getAllCourses(enrolled: true)
            seal(enrolledCourses)
        }
    }

    func unenrollAll() -> Promise<Void> {
        Promise { seal in
            let batchUpdateRequest = NSBatchUpdateRequest(entityName: Course.entityName)
            batchUpdateRequest.predicate = NSPredicate(format: "managedEnrolled == %@", NSNumber(value: true))
            batchUpdateRequest.propertiesToUpdate = ["managedEnrolled": NSNumber(value: false)]

            self.managedObjectContext.perform {
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

    func batchUpdateIsInWishlist(id: Course.IdType, isInWishList: Bool) -> Promise<Void> {
        Promise { seal in
            let batchUpdateRequest = NSBatchUpdateRequest(entityName: Course.entityName)
            batchUpdateRequest.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(Course.managedId),
                NSNumber(value: id)
            )
            batchUpdateRequest.propertiesToUpdate = ["managedIsInWishlist": NSNumber(value: isInWishList)]

            self.managedObjectContext.perform {
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
        case batchUpdateFailed
    }
}
