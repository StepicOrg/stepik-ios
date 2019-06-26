import Foundation
import PromiseKit

protocol StepsPersistenceServiceProtocol: class {
    func fetch(ids: [Step.IdType]) -> Promise<[Step]>
}

final class StepsPersistenceService: StepsPersistenceServiceProtocol {
    func fetch(ids: [Step.IdType]) -> Promise<[Step]> {
        return Promise { seal in
            Step.fetchAsync(ids: ids).done { steps in
                let steps = Array(Set(steps)).reordered(order: ids, transform: { $0.id })
                seal.fulfill(steps)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
