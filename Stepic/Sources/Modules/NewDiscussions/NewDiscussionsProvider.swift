import Foundation
import PromiseKit

protocol NewDiscussionsProviderProtocol {
    func fetchDiscussionProxy(id: DiscussionProxy.IdType) -> Promise<DiscussionProxy>
    func fetchComments(ids: [Comment.IdType]) -> Promise<[Comment]>
}

final class NewDiscussionsProvider: NewDiscussionsProviderProtocol {
    private let discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol
    private let commentsNetworkService: CommentsNetworkServiceProtocol

    init(
        discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol,
        commentsNetworkService: CommentsNetworkServiceProtocol
    ) {
        self.discussionProxiesNetworkService = discussionProxiesNetworkService
        self.commentsNetworkService = commentsNetworkService
    }

    func fetchDiscussionProxy(id: DiscussionProxy.IdType) -> Promise<DiscussionProxy> {
        return Promise { seal in
            self.discussionProxiesNetworkService.fetch(id: id).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchComments(ids: [Comment.IdType]) -> Promise<[Comment]> {
        return Promise { seal in
            self.commentsNetworkService.fetch(ids: ids).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
