import CoreData
import Foundation
import PromiseKit

protocol UserCoursePersistenceServiceProtocol: AnyObject {
    func fetch(ids: [UserCourse.IdType]) -> Guarantee<[UserCourse]>
    func fetch(courseID: Course.IdType) -> Guarantee<[UserCourse]>
    func fetchAll() -> Guarantee<[UserCourse]>

    func deleteAll() -> Promise<Void>
}

final class UserCoursePersistenceService: UserCoursePersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [UserCourse.IdType]) -> Guarantee<[UserCourse]> {
        Guarantee { seal in
            let request: NSFetchRequest<UserCourse> = UserCourse.fetchRequest

            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(UserCourse.managedId), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            request.predicate = compoundPredicate
            request.sortDescriptors = UserCourse.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
                do {
                    let userCourses = try self.managedObjectContext.fetch(request)
                    seal(userCourses)
                } catch {
                    print("UserCoursePersistenceService :: failed fetch ids = \(ids)")
                    seal([])
                }
            }
        }
    }

    func fetch(courseID: Course.IdType) -> Guarantee<[UserCourse]> {
        Guarantee { seal in
            let request: NSFetchRequest<UserCourse> = UserCourse.fetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(UserCourse.managedCourseId),
                NSNumber(value: courseID)
            )
            request.sortDescriptors = UserCourse.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
                do {
                    let userCourses = try self.managedObjectContext.fetch(request)
                    seal(userCourses)
                } catch {
                    print("UserCoursePersistenceService :: failed fetch by course id = \(courseID)")
                    seal([])
                }
            }
        }
    }

    func fetchAll() -> Guarantee<[UserCourse]> {
        Guarantee { seal in
            let request: NSFetchRequest<UserCourse> = UserCourse.fetchRequest
            request.sortDescriptors = UserCourse.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
                do {
                    let userCourses = try self.managedObjectContext.fetch(request)
                    seal(userCourses)
                } catch {
                    print("UserCoursePersistenceService :: failed fetch all")
                    seal([])
                }
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<UserCourse> = UserCourse.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let userCourses = try self.managedObjectContext.fetch(request)
                    for userCourse in userCourses {
                        self.managedObjectContext.delete(userCourse)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("UserCoursePersistenceService :: failed delete all user courses with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
