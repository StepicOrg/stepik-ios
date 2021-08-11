import CoreData
import PromiseKit

protocol ProgressesPersistenceServiceProtocol: AnyObject {
    func fetch(id: Progress.IdType) -> Promise<Progress?>
    func fetch(ids: [Progress.IdType], page: Int) -> Promise<([Progress], Meta)>

    func deleteAll() -> Promise<Void>
}

final class ProgressesPersistenceService: BasePersistenceService<Progress>, ProgressesPersistenceServiceProtocol {
    func fetch(id: Progress.IdType) -> Promise<Progress?> {
        firstly { () -> Guarantee<Progress?> in
            self.fetch(id: id)
        }
    }

    func fetch(ids: [Progress.IdType], page: Int = 1) -> Promise<([Progress], Meta)> {
        firstly { () -> Guarantee<[Progress]> in
            self.fetch(ids: ids)
        }.map { ($0, Meta.oneAndOnlyPage) }
    }
}
