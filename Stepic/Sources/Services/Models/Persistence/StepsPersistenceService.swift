import CoreData
import PromiseKit

protocol StepsPersistenceServiceProtocol: AnyObject {
    func fetch(id: Step.IdType) -> Promise<Step?>
    func fetch(ids: [Step.IdType]) -> Promise<[Step]>

    func deleteAll() -> Promise<Void>
}

final class StepsPersistenceService: BasePersistenceService<Step>, StepsPersistenceServiceProtocol {
    func fetch(id: Step.IdType) -> Promise<Step?> {
        firstly { () -> Guarantee<Step?> in
            self.fetch(id: id)
        }
    }

    func fetch(ids: [Step.IdType]) -> Promise<[Step]> {
        firstly { () -> Guarantee<[Step]> in
            self.fetch(ids: ids)
        }.map { $0.reordered(order: ids, transform: { $0.id }) }
    }
}
