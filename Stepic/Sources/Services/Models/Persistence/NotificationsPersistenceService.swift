import CoreData
import Foundation
import PromiseKit

protocol NotificationsPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class NotificationsPersistenceService: NotificationsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Notification> = Notification.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let notifications = try self.managedObjectContext.fetch(request)
                    for notification in notifications {
                        self.managedObjectContext.delete(notification)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("NotificationsPersistenceService :: failed delete all notification with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
