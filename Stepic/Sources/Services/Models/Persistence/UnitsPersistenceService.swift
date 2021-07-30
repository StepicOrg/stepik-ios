import CoreData
import PromiseKit

protocol UnitsPersistenceServiceProtocol: AnyObject {
    func fetch(id: Unit.IdType) -> Promise<Unit?>
    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]>

    func deleteAll() -> Promise<Void>
}

final class UnitsPersistenceService: BasePersistenceService<Unit>, UnitsPersistenceServiceProtocol {
    func fetch(id: Unit.IdType) -> Promise<Unit?> {
        firstly { () -> Guarantee<Unit?> in
            self.fetch(id: id)
        }
    }

    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]> {
        firstly { () -> Guarantee<[Unit]> in
            self.fetch(ids: ids)
        }.map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
