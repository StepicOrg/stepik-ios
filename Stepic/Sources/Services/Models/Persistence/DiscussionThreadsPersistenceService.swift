import CoreData
import Foundation
import PromiseKit

protocol DiscussionThreadsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [DiscussionThread.IdType]) -> Guarantee<[DiscussionThread]>

    func deleteAll() -> Promise<Void>
}

final class DiscussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [DiscussionThread.IdType]) -> Guarantee<[DiscussionThread]> {
        Guarantee { seal in
            DiscussionThread.fetchAsync(ids: ids).done { discussionThreads in
                let discussionThreads = Array(Set(discussionThreads)).reordered(order: ids, transform: { $0.id })
                seal(discussionThreads)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<DiscussionThread> = DiscussionThread.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let discussionThreads = try self.managedObjectContext.fetch(request)
                    for discussionThread in discussionThreads {
                        self.managedObjectContext.delete(discussionThread)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("DiscussionThreadsPersistenceService :: failed delete all threads with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
