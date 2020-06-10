import CoreData
import Foundation
import PromiseKit

protocol LastStepPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class LastStepPersistenceService: LastStepPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<LastStep> = LastStep.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let lastSteps = try self.managedObjectContext.fetch(request)
                    for lastStep in lastSteps {
                        self.managedObjectContext.delete(lastStep)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("LastStepPersistenceService :: failed delete all last steps with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
