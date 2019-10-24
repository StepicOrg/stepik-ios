import Foundation

protocol WriteCommentOutputProtocol: class {
    func handleCommentCreated(_ comment: Comment)
    func handleCommentUpdated(_ comment: Comment)
}
