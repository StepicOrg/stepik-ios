import CoreData
import PromiseKit

protocol CodeTemplatesPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class CodeTemplatesPersistenceService: BasePersistenceService<CodeTemplate>,
                                             CodeTemplatesPersistenceServiceProtocol {}
