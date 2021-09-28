import Foundation
import PromiseKit

protocol UserCoursesReviewsProviderProtocol {
    func fetchLeavedCourseReviewsFromCache() -> Promise<[CourseReview]>
    func fetchLeavedCourseReviewsFromRemote() -> Promise<[CourseReview]>

    func fetchPossibleCoursesFromCache() -> Promise<[Course]>
    func fetchPossibleCoursesFromRemote() -> Promise<[Course]>

    func deleteCourseReview(id: CourseReview.IdType) -> Promise<Void>
}

final class UserCoursesReviewsProvider: UserCoursesReviewsProviderProtocol {
    private let userAccountService: UserAccountServiceProtocol

    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol
    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol

    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol

    private let userCoursesNetworkService: UserCoursesNetworkServiceProtocol
    private let userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol

    private var currentUserID: User.IdType? { self.userAccountService.currentUserID }

    init(
        userAccountService: UserAccountServiceProtocol,
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol,
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        userCoursesNetworkService: UserCoursesNetworkServiceProtocol,
        userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol
    ) {
        self.userAccountService = userAccountService
        self.courseReviewsNetworkService = courseReviewsNetworkService
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.userCoursesNetworkService = userCoursesNetworkService
        self.userCoursesPersistenceService = userCoursesPersistenceService
    }

    func fetchLeavedCourseReviewsFromCache() -> Promise<[CourseReview]> {
        Promise { seal in
            guard let currentUserID = self.currentUserID else {
                throw Error.persistenceFetchFailed
            }

            self.fetchAndMergeCourseReviews(
                courseReviewsFetchMethod: { self.courseReviewsPersistenceService.fetch(userID: currentUserID) },
                coursesFetchMethod: self.coursesPersistenceService.fetch(ids:)
            ).done { reviews in
                seal.fulfill(reviews)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchLeavedCourseReviewsFromRemote() -> Promise<[CourseReview]> {
        Promise { seal in
            guard let currentUserID = self.currentUserID else {
                throw Error.networkFetchFailed
            }

            self.fetchAndMergeCourseReviews(
                courseReviewsFetchMethod: { self.courseReviewsNetworkService.fetchAll(userID: currentUserID) },
                coursesFetchMethod: self.coursesNetworkService.fetch(ids:)
            ).done { reviews in
                seal.fulfill(reviews)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchPossibleCoursesFromCache() -> Promise<[Course]> {
        Promise { seal in
            self.userCoursesPersistenceService.fetchCanBeReviewed().done { userCourses in
                let relationshipedCourses = userCourses.compactMap(\.course)
                if userCourses.count == relationshipedCourses.count {
                    return seal.fulfill(relationshipedCourses)
                }

                self.coursesPersistenceService.fetch(ids: userCourses.map(\.courseID)).done { courses in
                    CoreDataHelper.shared.context.performChanges {
                        let resultCourses = userCourses.compactMap { userCourse -> Course? in
                            if let course = courses.first(where: { $0.id == userCourse.courseID }) {
                                userCourse.course = course
                                return course
                            }
                            return nil
                        }
                        seal.fulfill(resultCourses)
                    }
                }.catch { _ in
                    seal.reject(Error.persistenceFetchFailed)
                }
            }
        }
    }

    func fetchPossibleCoursesFromRemote() -> Promise<[Course]> {
        Promise { seal in
            self.userCoursesNetworkService.fetchAllCanBeReviewedPages().then {
                userCourses -> Promise<([UserCourse], [Course])> in
                self.coursesNetworkService
                    .fetch(ids: userCourses.map(\.courseID))
                    .map { (userCourses, $0) }
            }.done { userCourses, courses in
                let orderedCourses = courses.reordered(order: userCourses.map(\.id), transform: \.id)
                let userCoursesMap = Dictionary(uniqueKeysWithValues: userCourses.map({ ($0.courseID, $0) }))

                CoreDataHelper.shared.context.performChanges {
                    for course in orderedCourses {
                        if let userCourse = userCoursesMap[course.id] {
                            userCourse.course = course
                        }
                    }

                    seal.fulfill(orderedCourses)
                }
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
        courseReviewsFetchMethod: @escaping () -> Promise<[CourseReview]>,
        coursesFetchMethod: @escaping ([Course.IdType]) -> Promise<[Course]>
    ) -> Promise<[CourseReview]> {
        courseReviewsFetchMethod().then { reviews -> Promise<([Course], [CourseReview])> in
            let coursesIDsToFetch = Array(Set(reviews.map(\.courseID)))
            return coursesFetchMethod(coursesIDsToFetch).map { ($0, reviews) }
        }.then { courses, reviews -> Promise<[CourseReview]> in
            for review in reviews {
                review.course = courses.first(where: { $0.id == review.courseID })
            }

            CoreDataHelper.shared.save()

            return .value(reviews)
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
        case deleteFailed
    }
}
