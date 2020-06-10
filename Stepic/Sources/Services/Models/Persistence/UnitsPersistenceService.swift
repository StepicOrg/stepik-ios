import CoreData
import Foundation
import PromiseKit

protocol UnitsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]>
    func fetch(id: Unit.IdType) -> Promise<Unit?>

    func deleteAll() -> Promise<Void>
}

final class UnitsPersistenceService: UnitsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Unit.IdType]) -> Promise<[Unit]> {
        Promise { seal in
            Unit.fetchAsync(ids: ids).done { units in
                let units = Array(Set(units)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(units)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Unit.IdType) -> Promise<Unit?> {
        Promise { seal in
            Unit.fetchAsync(ids: [id]).done { units in
                seal.fulfill(units.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Unit> = Unit.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let units = try self.managedObjectContext.fetch(request)
                    for unit in units {
                        self.managedObjectContext.delete(unit)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("UnitsPersistenceService :: failed delete all units with error = \(error)")
                    seal.reject(Error.fetchFailed)
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case deleteFailed
    }
}
