import Foundation
import PromiseKit

protocol CommentsNetworkServiceProtocol: class {
    func fetch(ids: [Comment.IdType]) -> Promise<[Comment]>
    func create(comment: Comment) -> Promise<Comment>
}

final class CommentsNetworkService: CommentsNetworkServiceProtocol {
    private let commentsAPI: CommentsAPI

    init(commentsAPI: CommentsAPI) {
        self.commentsAPI = commentsAPI
    }

    func fetch(ids: [Comment.IdType]) -> Promise<[Comment]> {
        if ids.isEmpty {
            return .value([])
        }

        return Promise { seal in
            self.commentsAPI.retrieve(ids: ids).done { comments in
                let comments = comments.reordered(order: ids, transform: { $0.id })
                seal.fulfill(comments)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func create(comment: Comment) -> Promise<Comment> {
        return Promise { seal in
            self.commentsAPI.create(comment).done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
