import CoreData
import Foundation
import PromiseKit

protocol VideoURLsPersistenceServiceProtocol: AnyObject {
    func deleteAll() -> Promise<Void>
}

final class VideoURLsPersistenceService: VideoURLsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<VideoURL> = VideoURL.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let videoURLs = try self.managedObjectContext.fetch(request)
                    for videoURL in videoURLs {
                        self.managedObjectContext.delete(videoURL)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("VideoURLsPersistenceService :: failed delete all video URLs with error = \(error)")
                    seal.reject(Error.deleteFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case deleteFailed
    }
}
