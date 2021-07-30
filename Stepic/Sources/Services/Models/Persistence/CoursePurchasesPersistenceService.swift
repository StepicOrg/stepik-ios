import CoreData
import PromiseKit

protocol CoursePurchasesPersistenceServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType) -> Guarantee<[CoursePurchase]>
    func fetchAll() -> Guarantee<[CoursePurchase]>

    func deleteAll() -> Promise<Void>
}

final class CoursePurchasesPersistenceService: BasePersistenceService<CoursePurchase>,
                                               CoursePurchasesPersistenceServiceProtocol {
    func fetch(courseID: Course.IdType) -> Guarantee<[CoursePurchase]> {
        Guarantee { seal in
            let request = CoursePurchase.sortedFetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CoursePurchase.managedCourseId),
                NSNumber(value: courseID)
            )
            request.returnsObjectsAsFaults = false

            do {
                let coursePurchases = try self.managedObjectContext.fetch(request)
                seal(coursePurchases)
            } catch {
                print("CoursePurchasesPersistenceService :: failed fetch by course id = \(courseID)")
                seal([])
            }
        }
    }
}
