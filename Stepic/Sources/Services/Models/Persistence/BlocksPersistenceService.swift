import CoreData
import Foundation
import PromiseKit

protocol BlocksPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class BlocksPersistenceService: BlocksPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Block> = Block.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let blocks = try self.managedObjectContext.fetch(request)
                    for block in blocks {
                        self.managedObjectContext.delete(block)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("BlocksPersistenceService :: failed delete all blocks with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
