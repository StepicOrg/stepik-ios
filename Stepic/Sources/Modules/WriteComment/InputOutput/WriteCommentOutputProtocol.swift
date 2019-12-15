import Foundation

protocol WriteCommentOutputProtocol: AnyObject {
    func handleCommentCreated(_ comment: Comment)
    func handleCommentUpdated(_ comment: Comment)
}
