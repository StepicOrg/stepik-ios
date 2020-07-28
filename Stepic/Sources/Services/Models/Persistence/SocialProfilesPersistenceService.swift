import CoreData
import Foundation
import PromiseKit

protocol SocialProfilesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [SocialProfile.IdType]) -> Promise<[SocialProfile]>
    func deleteAll() -> Promise<Void>
}

final class SocialProfilesPersistenceService: SocialProfilesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [SocialProfile.IdType]) -> Promise<[SocialProfile]> {
        Promise { seal in
            SocialProfile.fetchAsync(ids: ids).done { socialProfiles in
                seal.fulfill(socialProfiles)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<SocialProfile> = SocialProfile.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let socialProfiles = try self.managedObjectContext.fetch(request)
                    for socialProfile in socialProfiles {
                        self.managedObjectContext.delete(socialProfile)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("SocialProfilesPersistenceService :: failed delete all social profiles with error = \(error)")
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
