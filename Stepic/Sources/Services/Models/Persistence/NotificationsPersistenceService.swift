import CoreData
import PromiseKit

protocol NotificationsPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class NotificationsPersistenceService: BasePersistenceService<Notification>,
                                             NotificationsPersistenceServiceProtocol {}
