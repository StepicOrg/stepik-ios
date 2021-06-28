import Foundation

protocol CourseRevenueTabPurchasesOutputProtocol: AnyObject {
    func handleCourseRevenueTabPurchasesDidRequestPresentCourseInfo(courseID: Course.IdType)
    func handleCourseRevenueTabPurchasesDidRequestPresentUser(userID: User.IdType)
}
