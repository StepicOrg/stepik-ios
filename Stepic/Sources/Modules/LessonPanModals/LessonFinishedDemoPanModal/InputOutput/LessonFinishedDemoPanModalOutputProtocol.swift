import Foundation

protocol LessonFinishedDemoPanModalOutputProtocol: AnyObject {
    func handleLessonFinishedDemoPanModalMainAction()
    func handleLessonFinishedDemoPanModalDidAddCourseToWishlist(courseID: Course.IdType)
}
