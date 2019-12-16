import Foundation
import PromiseKit

protocol WriteCommentProviderProtocol {
    func create(comment: Comment) -> Promise<Comment>
    func update(comment: Comment) -> Promise<Comment>
}

final class WriteCommentProvider: WriteCommentProviderProtocol {
    private let commentsNetworkService: CommentsNetworkServiceProtocol

    init(commentsNetworkService: CommentsNetworkServiceProtocol) {
        self.commentsNetworkService = commentsNetworkService
    }

    func create(comment: Comment) -> Promise<Comment> {
        Promise { seal in
            self.commentsNetworkService.create(comment: comment).done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.networkCreateFailed)
            }
        }
    }

    func update(comment: Comment) -> Promise<Comment> {
        Promise { seal in
            self.commentsNetworkService.update(comment: comment).done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.networkUpdateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case networkCreateFailed
        case networkUpdateFailed
    }
}
