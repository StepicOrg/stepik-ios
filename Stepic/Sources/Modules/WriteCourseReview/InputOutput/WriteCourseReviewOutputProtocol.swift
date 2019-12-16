import Foundation

protocol WriteCourseReviewOutputProtocol: AnyObject {
    func handleCourseReviewCreated(_ courseReview: CourseReview)
    func handleCourseReviewUpdated(_ courseReview: CourseReview)
}
