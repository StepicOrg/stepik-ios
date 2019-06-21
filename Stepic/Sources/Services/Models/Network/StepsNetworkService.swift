import Foundation
import PromiseKit

protocol StepsNetworkServiceProtocol: class {
    func fetch(ids: [Step.IdType]) -> Promise<[Step]>
}

final class StepsNetworkService: StepsNetworkServiceProtocol {
    private let stepsAPI: StepsAPI

    init(stepsAPI: StepsAPI) {
        self.stepsAPI = stepsAPI
    }

    func fetch(ids: [Step.IdType]) -> Promise<[Step]> {
        return Promise { seal in
            self.stepsAPI.retrieve(ids: ids).done { steps in
                let steps = steps.reordered(order: ids, transform: { $0.id })
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
