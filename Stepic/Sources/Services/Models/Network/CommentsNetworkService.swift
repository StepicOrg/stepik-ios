import Foundation
import PromiseKit

protocol CommentsNetworkServiceProtocol: AnyObject {
    func fetch(ids: [Comment.IdType]) -> Promise<[Comment]>
    func create(comment: Comment) -> Promise<Comment>
    func update(comment: Comment) -> Promise<Comment>
    func delete(id: Comment.IdType) -> Promise<Void>
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
        Promise { seal in
            self.commentsAPI.create(comment).done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.createFailed)
            }
        }
    }

    func update(comment: Comment) -> Promise<Comment> {
        Promise { seal in
            self.commentsAPI.update(comment).done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.updateFailed)
            }
        }
    }

    func delete(id: Comment.IdType) -> Promise<Void> {
        Promise { seal in
            self.commentsAPI.delete(commentID: id).done {
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.deleteFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case createFailed
        case updateFailed
        case deleteFailed
    }
}
