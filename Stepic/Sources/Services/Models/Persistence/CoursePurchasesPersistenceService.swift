import CoreData
import Foundation
import PromiseKit

protocol CoursePurchasesPersistenceServiceProtocol: AnyObject {
    func fetch(courseID: Course.IdType) -> Guarantee<[CoursePurchase]>
    func fetchAll() -> Guarantee<[CoursePurchase]>

    func deleteAll() -> Promise<Void>
}

final class CoursePurchasesPersistenceService: CoursePurchasesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(courseID: Course.IdType) -> Guarantee<[CoursePurchase]> {
        Guarantee { seal in
            let request: NSFetchRequest<CoursePurchase> = CoursePurchase.fetchRequest
            request.predicate = NSPredicate(
                format: "%K == %@",
                #keyPath(CoursePurchase.managedCourseId),
                NSNumber(value: courseID)
            )
            request.sortDescriptors = CoursePurchase.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
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

    func fetchAll() -> Guarantee<[CoursePurchase]> {
        Guarantee { seal in
            let request: NSFetchRequest<CoursePurchase> = CoursePurchase.fetchRequest
            request.sortDescriptors = CoursePurchase.defaultSortDescriptors

            self.managedObjectContext.performAndWait {
                do {
                    let coursePurchases = try self.managedObjectContext.fetch(request)
                    seal(coursePurchases)
                } catch {
                    print("CoursePurchasesPersistenceService :: failed fetch all")
                    seal([])
                }
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<CoursePurchase> = CoursePurchase.fetchRequest

            self.managedObjectContext.performAndWait {
                do {
                    let coursePurchases = try self.managedObjectContext.fetch(request)
                    for coursePurchase in coursePurchases {
                        self.managedObjectContext.delete(coursePurchase)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CoursePurchasesPersistenceService :: failed delete all with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
