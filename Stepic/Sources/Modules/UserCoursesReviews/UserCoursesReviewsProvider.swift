import Foundation
import PromiseKit

protocol UserCoursesReviewsProviderProtocol {
    func fetchLeavedCourseReviewsFromCache(userID: User.IdType) -> Promise<([CourseReview], Meta)>
    func fetchLeavedCourseReviewsFromRemote(userID: User.IdType, page: Int) -> Promise<([CourseReview], Meta)>

    func deleteCourseReview(id: CourseReview.IdType) -> Promise<Void>
}

extension UserCoursesReviewsProviderProtocol {
    func fetchLeavedCourseReviewsFromRemoteOrCache(
        userID: User.IdType,
        page: Int = 1
    ) -> Promise<([CourseReview], Meta)> {
        Guarantee(
            self.fetchLeavedCourseReviewsFromRemote(userID: userID, page: page),
            fallback: nil
        ).then { remoteFetchResultOrNil -> Promise<([CourseReview], Meta)> in
            if let remoteFetchResult = remoteFetchResultOrNil.flatMap({ $0 }) {
                return .value(remoteFetchResult)
            } else {
                return self.fetchLeavedCourseReviewsFromCache(userID: userID)
            }
        }
    }
}

final class UserCoursesReviewsProvider: UserCoursesReviewsProviderProtocol {
    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol
    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol

    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    init(
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol,
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol
    ) {
        self.courseReviewsNetworkService = courseReviewsNetworkService
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
    }

    func fetchLeavedCourseReviewsFromCache(userID: User.IdType) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            self.fetchAndMergeCourseReviews(
                courseReviewsFetchMethod: {
                    self.courseReviewsPersistenceService.fetch(userID: userID).map { ($0, Meta.oneAndOnlyPage) }
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

    func fetchLeavedCourseReviewsFromRemote(userID: User.IdType, page: Int) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            self.fetchAndMergeCourseReviews(
                courseReviewsFetchMethod: { self.courseReviewsNetworkService.fetch(userID: userID) },
                coursesFetchMethod: self.coursesNetworkService.fetch(ids:)
            ).done { reviews, meta in
                seal.fulfill((reviews, meta))
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
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
        case persistenceFetchFailed
        case networkFetchFailed
        case deleteFailed
    }
}
