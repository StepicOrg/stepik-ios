import CoreData
import Foundation
import PromiseKit

protocol AssignmentsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Assignment.IdType]) -> Promise<[Assignment]>

    func deleteAll() -> Promise<Void>
}

final class AssignmentsPersistenceService: AssignmentsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Assignment.IdType]) -> Promise<[Assignment]> {
        Promise { seal in
            Assignment.fetchAsync(ids: ids).done { assignments in
                let assignments = Array(Set(assignments)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(assignments)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Assignment> = Assignment.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let assignments = try self.managedObjectContext.fetch(request)
                    for assignment in assignments {
                        self.managedObjectContext.delete(assignment)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("AssignmentsPersistenceService :: failed delete all assignments with error = \(error)")
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
