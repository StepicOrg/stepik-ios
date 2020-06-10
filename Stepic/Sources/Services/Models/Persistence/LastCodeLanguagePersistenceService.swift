import CoreData
import Foundation
import PromiseKit

protocol LastCodeLanguagePersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class LastCodeLanguagePersistenceService: LastCodeLanguagePersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<LastCodeLanguage> = LastCodeLanguage.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let lastCodeLanguages = try self.managedObjectContext.fetch(request)
                    for lastCodeLanguage in lastCodeLanguages {
                        self.managedObjectContext.delete(lastCodeLanguage)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("LastCodeLanguagePersistenceService :: failed delete all with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
