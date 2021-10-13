import CoreData
import PromiseKit

protocol UserActivitiesPersistenceServiceProtocol: AnyObject {
    func fetch(id: UserActivityEntity.IdType) -> Guarantee<UserActivityEntity?>
    func fetch(ids: [UserActivityEntity.IdType]) -> Guarantee<[UserActivityEntity]>

    func insert(userActivity: UserActivity) -> Guarantee<UserActivityEntity>

    func deleteAll() -> Promise<Void>
}

final class UserActivitiesPersistenceService: BasePersistenceService<UserActivityEntity>,
                                              UserActivitiesPersistenceServiceProtocol {
    func fetch(ids: [UserActivityEntity.IdType]) -> Guarantee<[UserActivityEntity]> {
        super.fetch(ids: ids).map { $0.reordered(order: ids, transform: { $0.id }) }
    }

    func insert(userActivity: UserActivity) -> Guarantee<UserActivityEntity> {
        Guarantee { seal in
            self.managedObjectContext.performChanges {
                let object = UserActivityEntity.insert(into: self.managedObjectContext, userActivity: userActivity)
                seal(object)
            }
        }
    }
}
