import CoreData
import PromiseKit

protocol UserCoursesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [UserCourse.IdType]) -> Guarantee<[UserCourse]>
    func fetch(courseID: Course.IdType) -> Guarantee<[UserCourse]>
    func fetchCanBeReviewed() -> Guarantee<[UserCourse]>
    func fetchAll() -> Guarantee<[UserCourse]>

    func deleteAll() -> Promise<Void>
}

final class UserCoursesPersistenceService: BasePersistenceService<UserCourse>, UserCoursesPersistenceServiceProtocol {
    func fetch(courseID: Course.IdType) -> Guarantee<[UserCourse]> {
        Guarantee { seal in
            let request = UserCourse.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(UserCourse.managedCourseId),
                NSNumber(value: courseID)
            )
            request.returnsObjectsAsFaults = false

            do {
                let userCourses = try self.managedObjectContext.fetch(request)
                seal(userCourses)
            } catch {
                print("UserCoursesPersistenceService :: failed fetch by course id = \(courseID)")
                seal([])
            }
        }
    }

    func fetchCanBeReviewed() -> Guarantee<[UserCourse]> {
        Guarantee { seal in
            let request = UserCourse.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(UserCourse.managedCanBeReviewed),
                NSNumber(value: true)
            )
            request.returnsObjectsAsFaults = false

            do {
                let userCourses = try self.managedObjectContext.fetch(request)
                seal(userCourses)
            } catch {
                print("UserCoursesPersistenceService :: failed fetch canBeReviewed with error = \(error)")
                seal([])
            }
        }
    }
}
