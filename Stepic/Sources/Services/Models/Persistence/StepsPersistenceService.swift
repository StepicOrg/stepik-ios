import CoreData
import Foundation
import PromiseKit

protocol StepsPersistenceServiceProtocol: AnyObject {
    func fetch(ids: [Step.IdType]) -> Promise<[Step]>
    func deleteAll() -> Promise<Void>
}

final class StepsPersistenceService: StepsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context) {
        self.managedObjectContext = managedObjectContext
    }

    func fetch(ids: [Step.IdType]) -> Promise<[Step]> {
        Promise { seal in
            Step.fetchAsync(ids: ids).done { steps in
                let steps = Array(Set(steps)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(steps)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<Step> = Step.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let steps = try self.managedObjectContext.fetch(request)
                    for step in steps {
                        self.managedObjectContext.delete(step)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("StepsPersistenceService :: failed delete all steps with error = \(error)")
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
