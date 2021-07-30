import CoreData
import PromiseKit

protocol UsersPersistenceServiceProtocol: AnyObject {
    func fetch(id: User.IdType) -> Guarantee<User?>
    func fetch(ids: [User.IdType]) -> Guarantee<[User]>
}

final class UsersPersistenceService: BasePersistenceService<User>, UsersPersistenceServiceProtocol {
    func fetch(ids: [User.IdType]) -> Guarantee<[User]> {
        super.fetch(ids: ids).map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
