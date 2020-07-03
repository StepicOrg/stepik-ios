import CoreData
import Foundation
import PromiseKit

protocol StepOptionsPersistenceServiceProtocol: AnyObject {
    func fetch(by stepID: Step.IdType) -> Promise<StepOptions?>
    func deleteAll() -> Promise<Void>
}

final class StepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol {
    private let managedObjectContext: NSManagedObjectContext
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context,
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService()
    ) {
        self.managedObjectContext = managedObjectContext
        self.stepsPersistenceService = stepsPersistenceService
    }

    func fetch(by stepID: Step.IdType) -> Promise<StepOptions?> {
        Promise { seal in
            self.stepsPersistenceService.fetch(ids: [stepID]).done { steps in
                seal.fulfill(steps.first?.options)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteAll() -> Promise<Void> {
        Promise { seal in
            let request: NSFetchRequest<StepOptions> = StepOptions.fetchRequest
            self.managedObjectContext.performAndWait {
                do {
                    let stepOptions = try self.managedObjectContext.fetch(request)
                    for stepOption in stepOptions {
                        self.managedObjectContext.delete(stepOption)
                    }

                    try? self.managedObjectContext.save()

                    seal.fulfill(())
                } catch {
                    print("StepOptionsPersistenceService :: failed delete all step options with error = \(error)")
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
