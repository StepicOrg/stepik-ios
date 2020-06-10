import CoreData
import Foundation
import PromiseKit

protocol ProgressesPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Progress.IdType], page: Int) -> Promise<([Progress], Meta)>
    func fetch(id: Progress.IdType) -> Promise<Progress?>

    func deleteAll() -> Promise<Void>
}

final class ProgressesPersistenceService: ProgressesPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Progress.IdType], page: Int = 1) -> Promise<([Progress], Meta)> {
        Promise { seal in
            Progress.fetchAsync(ids: ids).done { progresses in
                seal.fulfill((progresses, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Progress.IdType) -> Promise<Progress?> {
        Promise { seal in
            self.fetch(ids: [id]).done { progresses, _ in
                seal.fulfill(progresses.first)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Progress> = Progress.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let progresses = try self.managedObjectContext.fetch(request)
                    for progress in progresses {
                        self.managedObjectContext.delete(progress)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("ProgressesPersistenceService :: failed delete all progresses with error = \(error)")
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
