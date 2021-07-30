import CoreData
import PromiseKit

protocol StepOptionsPersistenceServiceProtocol: AnyObject {
    func fetch(by stepID: Step.IdType) -> Promise<StepOptions?>
    func deleteAll() -> Promise<Void>
}

final class StepOptionsPersistenceService: BasePersistenceService<StepOptions>, StepOptionsPersistenceServiceProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        managedObjectContext: NSManagedObjectContext = CoreDataHelper.shared.context,
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService()
    ) {
        self.stepsPersistenceService = stepsPersistenceService
        super.init(managedObjectContext: managedObjectContext)
    }

    func fetch(by stepID: Step.IdType) -> Promise<StepOptions?> {
        Promise { seal in
            self.stepsPersistenceService.fetch(id: stepID).done { stepOrNil in
                seal.fulfill(stepOrNil?.options)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
