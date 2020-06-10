import CoreData
import Foundation
import PromiseKit

protocol EmailAddressesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]>

    func deleteAll() -> Promise<Void>
}

final class EmailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [EmailAddress.IdType]) -> Promise<[EmailAddress]> {
        Promise { seal in
            EmailAddress.fetchAsync(ids: ids).done { emailAddresses in
                let emailAddresses = Array(Set(emailAddresses)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(emailAddresses)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<EmailAddress> = EmailAddress.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let emailAddresses = try self.managedObjectContext.fetch(request)
                    for emailAddress in emailAddresses {
                        self.managedObjectContext.delete(emailAddress)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("EmailAddressesPersistenceService :: failed delete all email adresses with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case deleteFailed
    }
}
