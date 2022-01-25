import Foundation

protocol LessonOutputProtocol: AnyObject {
    func handleLessonDidRequestBuyCourse()
    func handleLessonDidRequestLeaveReview()
    func handleLessonDidRequestPresentCatalog()
    func handleLessonDidAddCourseToWishlist(courseID: Course.IdType)
}
