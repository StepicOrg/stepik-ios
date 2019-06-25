import Foundation
import PromiseKit

protocol AttemptsNetworkServiceProtocol: class {
    func fetch(stepID: Step.IdType, blockName: String) -> Promise<([Attempt], Meta)>
    func create(stepID: Step.IdType, blockName: String) -> Promise<Attempt?>
}

final class AttemptsNetworkService: AttemptsNetworkServiceProtocol {
    private let attemptsAPI: AttemptsAPI

    init(attemptsAPI: AttemptsAPI) {
        self.attemptsAPI = attemptsAPI
    }

    func fetch(stepID: Step.IdType, blockName: String) -> Promise<([Attempt], Meta)> {
        return Promise { seal in
            self.attemptsAPI.retrieve(stepName: blockName, stepID: stepID).done { attempts, meta in
                seal.fulfill((attempts, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func create(stepID: Step.IdType, blockName: String) -> Promise<Attempt?> {
        return Promise { seal in
            self.attemptsAPI.create(stepName: blockName, stepId: stepID).done { attempt in
                seal.fulfill(attempt)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
