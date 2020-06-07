import CoreData
import Foundation
import PromiseKit

protocol VideosPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class VideosPersistenceService: VideosPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Video> = Video.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let videos = try self.managedObjectContext.fetch(request)
                    for video in videos {
                        self.managedObjectContext.delete(video)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("VideosPersistenceService :: failed delete all videos with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
