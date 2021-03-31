import CoreData
import Foundation
import PromiseKit

protocol ProctorSessionsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]>
    func deleteAll() -> Promise<Void>
}

final class ProctorSessionsPersistenceService: ProctorSessionsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [ProctorSession.IdType]) -> Promise<[ProctorSession]> {
        Promise { seal in
            ProctorSession.fetchAsync(ids: ids).done { proctorSessions in
                let result = Array(Set(proctorSessions)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(result)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            self.managedObjectContext.performAndWait {
                do {
                    let proctorSessions = try self.managedObjectContext.fetch(ProctorSession.fetchRequest)

                    for session in proctorSessions {
                        self.managedObjectContext.delete(session)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("ProctorSessionsPersistenceService :: failed delete all sessions with error = \(error)")
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
