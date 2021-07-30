import CoreData
import PromiseKit

protocol LastStepPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class LastStepPersistenceService: BasePersistenceService<LastStep>, LastStepPersistenceServiceProtocol {}
