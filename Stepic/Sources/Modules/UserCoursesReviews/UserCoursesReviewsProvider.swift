import Foundation
import PromiseKit

protocol UserCoursesReviewsProviderProtocol {
    func fetchLeavedCourseReviewsFromCache() -> Promise<([CourseReview], Meta)>
    func fetchLeavedCourseReviewsFromRemote(page: Int) -> Promise<([CourseReview], Meta)>

    func fetchPossibleCoursesFromCache() -> Promise<([Course], Meta)>

    func deleteCourseReview(id: CourseReview.IdType) -> Promise<Void>
}

extension UserCoursesReviewsProviderProtocol {
    func fetchLeavedCourseReviewsFromRemoteOrCache(page: Int = 1) -> Promise<([CourseReview], Meta)> {
        Guarantee(
            self.fetchLeavedCourseReviewsFromRemote(page: page),
            fallback: nil
        ).then { remoteFetchResultOrNil -> Promise<([CourseReview], Meta)> in
            if let remoteFetchResult = remoteFetchResultOrNil.flatMap({ $0 }) {
                return .value(remoteFetchResult)
            } else {
                return self.fetchLeavedCourseReviewsFromCache()
            }
        }
    }
}

final class UserCoursesReviewsProvider: UserCoursesReviewsProviderProtocol {
    private let userAccountService: UserAccountServiceProtocol

    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol
    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol

    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    private var currentUserID: User.IdType? { self.userAccountService.currentUserID }

    init(
        userAccountService: UserAccountServiceProtocol,
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol,
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.userAccountService = userAccountService
        self.courseReviewsNetworkService = courseReviewsNetworkService
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
    }

    func fetchLeavedCourseReviewsFromCache() -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            guard let currentUserID = self.currentUserID else {
                throw Error.invalidUserID
            }

            self.fetchAndMergeCourseReviews(
                courseReviewsFetchMethod: {
                    self.courseReviewsPersistenceService.fetch(userID: currentUserID).map { ($0, Meta.oneAndOnlyPage) }
                },
                coursesFetchMethod: { ids in
                    self.coursesPersistenceService.fetch(ids: ids).map { $0.0 }
                }
            ).done { reviews, meta in
                seal.fulfill((reviews, meta))
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchLeavedCourseReviewsFromRemote(page: Int) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            guard let currentUserID = self.currentUserID else {
                throw Error.invalidUserID
            }

            self.fetchAndMergeCourseReviews(
                courseReviewsFetchMethod: { self.courseReviewsNetworkService.fetch(userID: currentUserID, page: page) },
                coursesFetchMethod: self.coursesNetworkService.fetch(ids:)
            ).done { reviews, meta in
                seal.fulfill((reviews, meta))
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchPossibleCoursesFromCache() -> Promise<([Course], Meta)> {
        self.coursesPersistenceService
            .fetchEnrolled()
            .filterValues(\.canWriteReview)
            .map { (Array($0), Meta.oneAndOnlyPage) }
    }

    func deleteCourseReview(id: CourseReview.IdType) -> Promise<Void> {
        Promise { seal in
            self.courseReviewsNetworkService.delete(id: id).then { _ in
                self.courseReviewsPersistenceService.fetch(ids: [id])
            }.then { cachedReviews in
                when(resolved: cachedReviews.map({ self.courseReviewsPersistenceService.delete(by: $0.id) }))
            }.done { _ in
                CoreDataHelper.shared.save()
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.deleteFailed)
            }
        }
    }

    // MARK: Private API

    private func fetchAndMergeCourseReviews(
        courseReviewsFetchMethod: @escaping () -> Promise<([CourseReview], Meta)>,
        coursesFetchMethod: @escaping ([Course.IdType]) -> Promise<[Course]>
    ) -> Promise<([CourseReview], Meta)> {
        courseReviewsFetchMethod().then { reviews, meta -> Promise<([Course], [CourseReview], Meta)> in
            let coursesIDsToFetch = Array(Set(reviews.map(\.courseID)))
            return coursesFetchMethod(coursesIDsToFetch).map { ($0, reviews, meta) }
        }.then { courses, reviews, meta -> Promise<([CourseReview], Meta)> in
            for review in reviews {
                review.course = courses.first(where: { $0.id == review.courseID })
            }

            CoreDataHelper.shared.save()

            return .value((reviews, meta))
        }
    }

    enum Error: Swift.Error {
        case invalidUserID
        case persistenceFetchFailed
        case networkFetchFailed
        case deleteFailed
    }
}
