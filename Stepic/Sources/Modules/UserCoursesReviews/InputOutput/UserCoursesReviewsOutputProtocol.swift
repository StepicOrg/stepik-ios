import Foundation

protocol UserCoursesReviewsOutputProtocol: AnyObject {
    func handleUserCoursesReviewsCountsChanged(possibleReviewsCount: Int, leavedCourseReviewsCount: Int)
}
