import CoreData
import PromiseKit

protocol BlocksPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class BlocksPersistenceService: BasePersistenceService<Block>, BlocksPersistenceServiceProtocol {}
