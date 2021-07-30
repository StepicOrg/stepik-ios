import CoreData
import PromiseKit

protocol SectionsPersistenceServiceProtocol: AnyObject {
    func fetch(id: Section.IdType) -> Promise<Section?>
    func fetch(ids: [Section.IdType]) -> Promise<[Section]>

    func deleteAll() -> Promise<Void>
}

final class SectionsPersistenceService: BasePersistenceService<Section>, SectionsPersistenceServiceProtocol {
    func fetch(id: Section.IdType) -> Promise<Section?> {
        firstly { () -> Guarantee<Section?> in
            self.fetch(id: id)
        }
    }

    func fetch(ids: [Section.IdType]) -> Promise<[Section]> {
        firstly { () -> Guarantee<[Section]> in
            self.fetch(ids: ids)
        }.map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
