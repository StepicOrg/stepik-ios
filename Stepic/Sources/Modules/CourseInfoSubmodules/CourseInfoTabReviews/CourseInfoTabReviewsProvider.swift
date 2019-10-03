import Foundation
import PromiseKit

protocol CourseInfoTabReviewsProviderProtocol: class {
    func fetchCached(course: Course) -> Promise<([CourseReview], Meta)>
    func fetchRemote(course: Course, page: Int) -> Promise<([CourseReview], Meta)>

    func fetchCurrentUserReviewCached(course: Course) -> Promise<CourseReview?>
    func fetchCurrentUserReviewRemote(course: Course) -> Promise<CourseReview?>
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
        return Promise { seal in
            self.courseReviewsPersistenceService.fetch(by: course.id).done {
                seal.fulfill(($0, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote(course: Course, page: Int) -> Promise<([CourseReview], Meta)> {
        return Promise { seal in
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
                CoreDataHelper.instance.save()
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCurrentUserReviewCached(course: Course) -> Promise<CourseReview?> {
        guard let currentUserID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.persistenceFetchFailed)
        }

        return Promise { seal in
            self.courseReviewsPersistenceService.fetch(by: course.id, userID: currentUserID).done {
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
                CoreDataHelper.instance.save()
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
