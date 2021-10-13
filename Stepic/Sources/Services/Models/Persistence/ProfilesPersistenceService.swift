import CoreData
import PromiseKit

protocol ProfilesPersistenceServiceProtocol: AnyObject {
    func fetch(id: Profile.IdType) -> Guarantee<Profile?>
    func fetch(ids: [Profile.IdType]) -> Guarantee<[Profile]>

    func deleteAll() -> Promise<Void>
}

final class ProfilesPersistenceService: BasePersistenceService<Profile>, ProfilesPersistenceServiceProtocol {
    func fetch(ids: [Profile.IdType]) -> Guarantee<[Profile]> {
        super.fetch(ids: ids).map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
