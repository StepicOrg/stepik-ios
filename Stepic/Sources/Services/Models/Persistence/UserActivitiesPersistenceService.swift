import CoreData
import Foundation
import PromiseKit

protocol UserActivitiesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [UserActivityEntity.IdType]) -> Guarantee<[UserActivityEntity]>
    func fetch(id: UserActivityEntity.IdType) -> Guarantee<UserActivityEntity?>
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

    private func fetchUserActivities(ids: [UserActivityEntity.IdType]) -> Guarantee<[UserActivityEntity]> {
        Guarantee { seal in
            let idSubpredicates = ids.map { id in
                NSPredicate(format: "%K == %@", #keyPath(UserActivityEntity.managedId), NSNumber(value: id))
            }
            let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idSubpredicates)

            let request: NSFetchRequest<UserActivityEntity> = UserActivityEntity.fetchRequest()
            request.predicate = compoundPredicate
            request.sortDescriptors = UserActivityEntity.defaultSortDescriptors
            request.returnsObjectsAsFaults = false

            self.managedObjectContext.performAndWait {
                do {
                    let userActivities = try self.managedObjectContext.fetch(request)
                    seal(userActivities)
                } catch {
                    print("Error while fetching user activities = \(ids)")
                    seal([])
                }
            }
        }
    }
}
