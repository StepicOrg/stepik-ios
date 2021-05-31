import Foundation

protocol LessonOutputProtocol: AnyObject {
    func handleLessonDidRequestBuyCourse()
    func handleLessonDidRequestLeaveReview()
    func handleLessonDidRequestPresentCatalog()
}
