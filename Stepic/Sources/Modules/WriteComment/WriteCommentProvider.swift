import Foundation
import PromiseKit

protocol WriteCommentProviderProtocol {
    func create(
        targetID: WriteComment.TargetIDType,
        parentID: WriteComment.ParentIDtype?,
        text: String
    ) -> Promise<Comment>
}

final class WriteCommentProvider: WriteCommentProviderProtocol {
    private let commentsNetworkService: CommentsNetworkServiceProtocol

    init(commentsNetworkService: CommentsNetworkServiceProtocol) {
        self.commentsNetworkService = commentsNetworkService
    }

    func create(
        targetID: WriteComment.TargetIDType,
        parentID: WriteComment.ParentIDtype?,
        text: String
    ) -> Promise<Comment> {
        return Promise { seal in
            self.commentsNetworkService.create(
                comment: Comment(parent: parentID, target: targetID, text: text)
            ).done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.networkCreateFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case networkCreateFailed
        case networkUpdateFailed
    }
}
