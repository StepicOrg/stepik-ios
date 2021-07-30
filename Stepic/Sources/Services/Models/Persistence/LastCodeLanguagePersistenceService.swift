import CoreData
import PromiseKit

protocol LastCodeLanguagePersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class LastCodeLanguagePersistenceService: BasePersistenceService<LastCodeLanguage>,
                                                LastCodeLanguagePersistenceServiceProtocol {}
