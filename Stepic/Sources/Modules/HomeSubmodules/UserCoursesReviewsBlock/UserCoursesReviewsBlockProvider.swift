import Foundation
import PromiseKit

protocol UserCoursesReviewsBlockProviderProtocol: UserCoursesReviewsProviderProtocol {}

final class UserCoursesReviewsBlockProvider: UserCoursesReviewsBlockProviderProtocol {
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

    func deleteCourseReview(id: CourseReview.IdType) -> Promise<Void> {
        self.userCoursesReviewsProvider.deleteCourseReview(id: id)
    }
}
