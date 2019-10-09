import Foundation

protocol WriteCourseReviewOutputProtocol: class {
    func handleCourseReviewCreated(_ courseReview: CourseReview)
    func handleCourseReviewUpdated(_ courseReview: CourseReview)
}
