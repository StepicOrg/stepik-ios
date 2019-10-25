import Foundation
import PromiseKit

protocol NewDiscussionsProviderProtocol {
    func fetchDiscussionProxy(id: DiscussionProxy.IdType) -> Promise<DiscussionProxy>
    func fetchComments(ids: [Comment.IdType]) -> Promise<[Comment]>
    func deleteComment(id: Comment.IdType) -> Promise<Void>
    func updateVote(_ vote: Vote) -> Promise<Vote>
}

final class NewDiscussionsProvider: NewDiscussionsProviderProtocol {
    private let discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol
    private let commentsNetworkService: CommentsNetworkServiceProtocol
    private let votesNetworkService: VotesNetworkServiceProtocol

    init(
        discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol,
        commentsNetworkService: CommentsNetworkServiceProtocol,
        votesNetworkService: VotesNetworkServiceProtocol
    ) {
        self.discussionProxiesNetworkService = discussionProxiesNetworkService
        self.commentsNetworkService = commentsNetworkService
        self.votesNetworkService = votesNetworkService
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

    func deleteComment(id: Comment.IdType) -> Promise<Void> {
        return Promise { seal in
            self.commentsNetworkService.delete(id: id).done {
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.commentDeleteFailed)
            }
        }
    }

    func updateVote(_ vote: Vote) -> Promise<Vote> {
        return Promise { seal in
            self.votesNetworkService.update(vote: vote).done { vote in
                seal.fulfill(vote)
            }.catch { _ in
                seal.reject(Error.voteUpdateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case commentDeleteFailed
        case voteUpdateFailed
    }
}
