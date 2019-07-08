import Foundation
import PromiseKit

protocol VotesNetworkServiceProtocol: class {
    func update(vote: Vote) -> Promise<Vote>
}

final class VotesNetworkService: VotesNetworkServiceProtocol {
    private let votesAPI: VotesAPI

    init(votesAPI: VotesAPI) {
        self.votesAPI = votesAPI
    }

    func update(vote: Vote) -> Promise<Vote> {
        return Promise { seal in
            self.votesAPI.update(vote).done { vote in
                seal.fulfill(vote)
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case updateFailed
    }
}
