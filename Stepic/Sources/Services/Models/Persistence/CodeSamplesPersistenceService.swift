import CoreData
import PromiseKit

protocol CodeSamplesPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class CodeSamplesPersistenceService: BasePersistenceService<CodeSample>, CodeSamplesPersistenceServiceProtocol {}
