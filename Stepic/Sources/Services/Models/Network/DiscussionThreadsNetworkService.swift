import Foundation
import PromiseKit

protocol DiscussionThreadsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [DiscussionThread.IdType], page: Int) -> Promise<([DiscussionThread], Meta)>
}

extension DiscussionThreadsNetworkServiceProtocol {
    func fetch(ids: [DiscussionThread.IdType]) -> Promise<([DiscussionThread], Meta)> {
        self.fetch(ids: ids, page: 1)
    }
}

final class DiscussionThreadsNetworkService: DiscussionThreadsNetworkServiceProtocol {
    private let discussionThreadsAPI: DiscussionThreadsAPI

    init(discussionThreadsAPI: DiscussionThreadsAPI) {
        self.discussionThreadsAPI = discussionThreadsAPI
    }

    func fetch(ids: [DiscussionThread.IdType], page: Int) -> Promise<([DiscussionThread], Meta)> {
        if ids.isEmpty {
            return Promise.value(([], Meta.oneAndOnlyPage))
        }

        return Promise { seal in
            self.discussionThreadsAPI.retrieve(ids: ids, page: page).done { discussionThreads, meta in
                let discussionThreads = discussionThreads.reordered(order: ids, transform: { $0.id })
                seal.fulfill((discussionThreads, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
