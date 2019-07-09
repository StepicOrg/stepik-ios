import Foundation
import PromiseKit

protocol DiscussionProxiesNetworkServiceProtocol: class {
    func fetch(id: DiscussionProxy.IdType) -> Promise<DiscussionProxy>
}

final class DiscussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol {
    private let discussionProxiesAPI: DiscussionProxiesAPI

    init(discussionProxiesAPI: DiscussionProxiesAPI) {
        self.discussionProxiesAPI = discussionProxiesAPI
    }

    func fetch(id: DiscussionProxy.IdType) -> Promise<DiscussionProxy> {
        return Promise { seal in
            self.discussionProxiesAPI.retrieve(id: id).done { discussionProxy in
                seal.fulfill(discussionProxy)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
