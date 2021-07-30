import CoreData
import PromiseKit

protocol ProctorSessionsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]>
    func deleteAll() -> Promise<Void>
}

final class ProctorSessionsPersistenceService: BasePersistenceService<ProctorSession>,
                                               ProctorSessionsPersistenceServiceProtocol {
    func fetch(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]> {
        firstly { () -> Guarantee<[ProctorSession]> in
            self.fetch(ids: ids)
        }.map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
