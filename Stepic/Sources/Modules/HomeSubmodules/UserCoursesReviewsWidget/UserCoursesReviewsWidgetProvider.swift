import Foundation
import PromiseKit

protocol UserCoursesReviewsWidgetProviderProtocol: UserCoursesReviewsProviderProtocol {}

final class UserCoursesReviewsWidgetProvider: UserCoursesReviewsWidgetProviderProtocol {
    private let userCoursesReviewsProvider: UserCoursesReviewsProviderProtocol

    init(userCoursesReviewsProvider: UserCoursesReviewsProviderProtocol) {
        self.userCoursesReviewsProvider = userCoursesReviewsProvider
    }

    func fetchLeavedCourseReviewsFromCache() -> Promise<[CourseReview]> {
        self.userCoursesReviewsProvider.fetchLeavedCourseReviewsFromCache()
    }

    func fetchLeavedCourseReviewsFromRemote() -> Promise<[CourseReview]> {
        self.userCoursesReviewsProvider.fetchLeavedCourseReviewsFromRemote()
    }

    func fetchPossibleCoursesFromCache() -> Promise<[Course]> {
        self.userCoursesReviewsProvider.fetchPossibleCoursesFromCache()
    }

    func fetchPossibleCoursesFromRemote() -> Promise<[Course]> {
        self.userCoursesReviewsProvider.fetchPossibleCoursesFromRemote()
    }

    func deleteCourseReview(id: CourseReview.IdType) -> Promise<Void> {
        self.userCoursesReviewsProvider.deleteCourseReview(id: id)
    }
}
