import CoreData
import Foundation
import PromiseKit

protocol UserActivitiesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [UserActivityEntity.IdType]) -> Guarantee<[UserActivityEntity]>
    func fetch(id: UserActivityEntity.IdType) -> Guarantee<UserActivityEntity?>
    func create(userActivity: UserActivity) -> Guarantee<UserActivityEntity>

    func deleteAll() -> Promise<Void>
}

final class UserActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [UserActivityEntity.IdType]) -> Guarantee<[UserActivityEntity]> {
        firstly {
            self.fetchUserActivities(ids: ids)
        }.map { userActivities in
            Array(Set(userActivities)).reordered(order: ids, transform: { $0.id })
        }
    }

    func fetch(id: UserActivityEntity.IdType) -> Guarantee<UserActivityEntity?> {
        firstly {
            self.fetchUserActivities(ids: [id])
        }.then { userActivities in
            .value(userActivities.first)
        }
    }

    func create(userActivity: UserActivity) -> Guarantee<UserActivityEntity> {
        Guarantee { seal in
            self.managedObjectContext.performAndWait {
                let entity = UserActivityEntity()
                entity.id = userActivity.id
                entity.pins = userActivity.pins

                try? self.managedObjectContext.save()

                seal(entity)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<UserActivityEntity> = UserActivityEntity.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let userActivities = try self.managedObjectContext.fetch(request)
                    for userActivity in userActivities {
                        self.managedObjectContext.delete(userActivity)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("UserActivitiesPersistenceService :: failed delete all user activities = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    private func fetchUserActivities(ids: [UserActivityEntity.IdType]) -> Guarantee<[UserActivityEntity]> {
        Guarantee { seal in
            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(UserActivityEntity.managedId), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            let request: NSFetchRequest<UserActivityEntity> = UserActivityEntity.fetchRequest
            request.predicate = compoundPredicate
            request.sortDescriptors = UserActivityEntity.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let userActivities = try self.managedObjectContext.fetch(request)
                    seal(userActivities)
                } catch {
                    print("UserActivitiesPersistenceService :: failed fetch user activities = \(ids)")
                    seal([])
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
