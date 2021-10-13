import Foundation

protocol CourseBenefitDetailOutputProtocol: AnyObject {
    func handleCourseBenefitDetailDidRequestPresentCourseInfo(courseID: Course.IdType)
    func handleCourseBenefitDetailDidRequestPresentUser(userID: User.IdType)
}
