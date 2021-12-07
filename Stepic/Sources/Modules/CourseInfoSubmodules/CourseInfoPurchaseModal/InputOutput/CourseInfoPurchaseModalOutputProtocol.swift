import Foundation

protocol CourseInfoPurchaseModalOutputProtocol: AnyObject {
    func handleCourseInfoPurchaseModalDidAddCourseToWishlist(courseID: Course.IdType)
    func handleCourseInfoPurchaseModalDidRequestStartLearning(courseID: Course.IdType)
}
