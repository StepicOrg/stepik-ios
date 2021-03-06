import Foundation
import PromiseKit

protocol ProgressesNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Progress.IdType], page: Int) -> Promise<([Progress], Meta)>
    func fetch(id: Progress.IdType) -> Promise<Progress?>
}

extension ProgressesNetworkServiceProtocol {
    func fetch(ids: [Progress.IdType]) -> Promise<[Progress]> {
        self.fetch(ids: ids, page: 1).map { $0.0 }
    }
}

final class ProgressesNetworkService: ProgressesNetworkServiceProtocol {
    private let progressesAPI: ProgressesAPI

    init(progressesAPI: ProgressesAPI) {
        self.progressesAPI = progressesAPI
    }

    func fetch(ids: [Progress.IdType], page: Int = 1) -> Promise<([Progress], Meta)> {
        if ids.isEmpty {
            return .value(([], Meta.oneAndOnlyPage))
        }

        // FIXME: We have no pagination here but should support it
        return Promise { seal in
            self.progressesAPI.retrieve(ids: ids).done { progresses in
                let progresses = progresses.reordered(order: ids, transform: { $0.id })
                seal.fulfill((progresses, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetch(id: Progress.IdType) -> Promise<Progress?> {
        Promise { seal in
            self.progressesAPI.retrieve(ids: [id]).done { progresses in
                seal.fulfill(progresses.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
