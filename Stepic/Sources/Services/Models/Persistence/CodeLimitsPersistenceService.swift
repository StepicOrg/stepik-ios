import CoreData
import Foundation
import PromiseKit

protocol CodeLimitsPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class CodeLimitsPersistenceService: CodeLimitsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<CodeLimit> = CodeLimit.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let codeLimits = try self.managedObjectContext.fetch(request)
                    for codeLimit in codeLimits {
                        self.managedObjectContext.delete(codeLimit)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("CodeLimitsPersistenceService :: failed delete all code limits with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
