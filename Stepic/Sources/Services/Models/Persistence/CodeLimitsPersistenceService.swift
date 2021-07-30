import CoreData
import PromiseKit

protocol CodeLimitsPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class CodeLimitsPersistenceService: BasePersistenceService<CodeLimit>, CodeLimitsPersistenceServiceProtocol {}
