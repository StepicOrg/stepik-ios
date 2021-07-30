import CoreData
import PromiseKit

protocol AssignmentsPersistenceServiceProtocol: AnyObject {
    func fetch(id: Assignment.IdType) -> Guarantee<Assignment?>
    func fetch(ids: [Assignment.IdType]) -> Guarantee<[Assignment]>

    func deleteAll() -> Promise<Void>
}

final class AssignmentsPersistenceService: BasePersistenceService<Assignment>, AssignmentsPersistenceServiceProtocol {
    func fetch(ids: [Assignment.IdType]) -> Guarantee<[Assignment]> {
        super.fetch(ids: ids).map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
