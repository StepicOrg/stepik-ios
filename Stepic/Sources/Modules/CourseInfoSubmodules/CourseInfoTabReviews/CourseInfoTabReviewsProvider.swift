import Foundation
import PromiseKit

protocol CourseInfoTabReviewsProviderProtocol: AnyObject {
    func fetchCached(course: Course) -> Promise<([CourseReview], Meta)>
    func fetchRemote(course: Course, page: Int) -> Promise<([CourseReview], Meta)>
    func fetchCachedCourseReview(courseReviewID: CourseReview.IdType) -> Guarantee<CourseReview?>

    func fetchCurrentUserReviewCached(course: Course) -> Promise<CourseReview?>
    func fetchCurrentUserReviewRemote(course: Course) -> Promise<CourseReview?>

    func delete(id: CourseReview.IdType) -> Promise<Void>
}

final class CourseInfoTabReviewsProvider: CourseInfoTabReviewsProviderProtocol {
    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol
    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol
    private let usersNetworkService: UsersNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol,
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol,
        usersNetworkService: UsersNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.courseReviewsNetworkService = courseReviewsNetworkService
        self.usersNetworkService = usersNetworkService
        self.userAccountService = userAccountService
    }

    func fetchCached(course: Course) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            self.courseReviewsPersistenceService.fetch(courseID: course.id).done {
                seal.fulfill(($0, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote(course: Course, page: Int) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            self.courseReviewsNetworkService.fetch(by: course.id, page: page).then {
                reviews, meta -> Promise<([User], [CourseReview], Meta)> in
                let userIDsToFetch = reviews.map { $0.userID }
                return self.usersNetworkService.fetch(ids: userIDsToFetch).map { ($0, reviews, meta) }
            }.done { users, reviews, meta in
                for review in reviews {
                    review.course = course
                    review.user = users.first { $0.id == review.userID }
                }

                seal.fulfill((reviews, meta))
                CoreDataHelper.shared.save()
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCachedCourseReview(courseReviewID: CourseReview.IdType) -> Guarantee<CourseReview?> {
        Guarantee { seal in
            self.courseReviewsPersistenceService.fetch(ids: [courseReviewID]).done { courseReviews in
                seal(courseReviews.first)
            }
        }
    }

    func fetchCurrentUserReviewCached(course: Course) -> Promise<CourseReview?> {
        guard let currentUserID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.persistenceFetchFailed)
        }

        return Promise { seal in
            self.courseReviewsPersistenceService.fetch(courseID: course.id, userID: currentUserID).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchCurrentUserReviewRemote(course: Course) -> Promise<CourseReview?> {
        guard let currentUserID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.networkFetchFailed)
        }

        return Promise { seal in
            when(
                fulfilled:
                    self.usersNetworkService.fetch(id: currentUserID),
                self.courseReviewsNetworkService.fetch(courseID: course.id, userID: currentUserID)
            ).done { user, reviewsResult in
                let review = reviewsResult.0.first
                review?.course = course
                review?.user = user

                seal.fulfill(review)
                CoreDataHelper.shared.save()
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func delete(id: CourseReview.IdType) -> Promise<Void> {
        Promise { seal in
            self.courseReviewsNetworkService.delete(id: id).then { _ in
                self.courseReviewsPersistenceService.fetch(ids: [id])
            }.then { cachedReviews in
                when(resolved: cachedReviews.map({ self.courseReviewsPersistenceService.delete(by: $0.id) }))
            }.done { _ in
                seal.fulfill(())
                CoreDataHelper.shared.save()
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
