import Foundation
import PromiseKit

protocol AttemptsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Attempt.IdType], blockName: String) -> Promise<[Attempt]>
    func fetch(stepID: Step.IdType, userID: User.IdType, blockName: String) -> Promise<([Attempt], Meta)>
    func create(stepID: Step.IdType, blockName: String) -> Promise<Attempt>
}

final class AttemptsNetworkService: AttemptsNetworkServiceProtocol {
    private let attemptsAPI: AttemptsAPI

    init(attemptsAPI: AttemptsAPI) {
        self.attemptsAPI = attemptsAPI
    }

    func fetch(ids: [Attempt.IdType], blockName: String) -> Promise<[Attempt]> {
        Promise { seal in
            self.attemptsAPI.retrieve(ids: ids, stepName: blockName).done { attempts in
                seal.fulfill(attempts)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(stepID: Step.IdType, userID: User.IdType, blockName: String) -> Promise<([Attempt], Meta)> {
        Promise { seal in
            self.attemptsAPI.retrieve(stepName: blockName, stepID: stepID, userID: userID).done { attempts, meta in
                seal.fulfill((attempts, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func create(stepID: Step.IdType, blockName: String) -> Promise<Attempt> {
        Promise { seal in
            self.attemptsAPI.create(stepName: blockName, stepID: stepID).done { attempt in
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
