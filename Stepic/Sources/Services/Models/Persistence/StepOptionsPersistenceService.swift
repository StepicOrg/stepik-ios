import Foundation
import PromiseKit

protocol StepOptionsPersistenceServiceProtocol: class {
    func fetch(by stepID: Step.IdType) -> Promise<StepOptions?>
}

final class StepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol {
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(stepsPersistenceService: StepsPersistenceServiceProtocol) {
        self.stepsPersistenceService = stepsPersistenceService
    }

    func fetch(by stepID: Step.IdType) -> Promise<StepOptions?> {
        return Promise { seal in
            self.stepsPersistenceService.fetch(ids: [stepID]).done { steps in
                seal.fulfill(steps.first?.options)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
