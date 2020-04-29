import Foundation
import PromiseKit

protocol CourseInfoProviderProtocol {
    func fetchCached() -> Promise<Course?>
    func fetchRemote() -> Promise<Course?>

    func fetchUserCourse(courseID: Course.IdType) -> Promise<UserCourse?>
    func updateUserCourse(userCourse: UserCourse) -> Promise<UserCourse>
}

final class CourseInfoProvider: CourseInfoProviderProtocol {
    private let courseID: Course.IdType

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol

    private let reviewSummariesPersistenceService: CourseReviewSummariesPersistenceServiceProtocol
    private let reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol

    private let userCoursesNetworkService: UserCoursesNetworkServiceProtocol

    init(
        courseID: Course.IdType,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        reviewSummariesPersistenceService: CourseReviewSummariesPersistenceServiceProtocol,
        reviewSummariesNetworkService: CourseReviewSummariesNetworkServiceProtocol,
        userCoursesNetworkService: UserCoursesNetworkServiceProtocol
    ) {
        self.courseID = courseID
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.progressesPersistenceService = progressesPersistenceService
        self.reviewSummariesNetworkService = reviewSummariesNetworkService
        self.reviewSummariesPersistenceService = reviewSummariesPersistenceService
        self.userCoursesNetworkService = userCoursesNetworkService
    }

    func fetchCached() -> Promise<Course?> {
        Promise { seal in
            self.fetchAndMergeCourse(
                courseFetchMethod: self.coursesPersistenceService.fetch(id:),
                progressFetchMethod: self.progressesPersistenceService.fetch(id:),
                reviewSummaryFetchMethod: self.reviewSummariesPersistenceService.fetch(id:)
            ).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote() -> Promise<Course?> {
        Promise { seal in
            self.fetchAndMergeCourse(
                courseFetchMethod: self.coursesNetworkService.fetch(id:),
                progressFetchMethod: self.progressesNetworkService.fetch(id:),
                reviewSummaryFetchMethod: self.reviewSummariesNetworkService.fetch(id:)
            ).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchUserCourse(courseID: Course.IdType) -> Promise<UserCourse?> {
        Promise { seal in
            self.userCoursesNetworkService.fetch(courseID: courseID).done { userCourse in
                seal.fulfill(userCourse)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func updateUserCourse(userCourse: UserCourse) -> Promise<UserCourse> {
        Promise { seal in
            self.userCoursesNetworkService.update(userCourse: userCourse).done { userCourse in
                seal.fulfill(userCourse)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    private func fetchAndMergeCourse(
        courseFetchMethod: @escaping (Course.IdType) -> Promise<Course?>,
        progressFetchMethod: @escaping (Progress.IdType) -> Promise<Progress?>,
        reviewSummaryFetchMethod: @escaping (CourseReviewSummary.IdType) -> Promise<CourseReviewSummary?>
    ) -> Promise<Course?> {
        Promise { seal in
            courseFetchMethod(self.courseID).then {
                course -> Promise<(Course?, Progress?, CourseReviewSummary?)> in
                let progressFetch: Promise<Progress?> = {
                    if let result = course?.progressId {
                        return progressFetchMethod(result)
                    }
                    return .value(nil)
                }()

                let reviewSummaryFetch: Promise<CourseReviewSummary?> = {
                    if let result = course?.reviewSummaryId {
                        return reviewSummaryFetchMethod(result)
                    }
                    return .value(nil)
                }()

                return when(fulfilled: Promise.value(course), progressFetch, reviewSummaryFetch)
            }.done { course, progress, reviewSummary in
                guard let course = course else {
                    seal.fulfill(nil)
                    return
                }

                course.progress = progress
                course.reviewSummary = reviewSummary

                CoreDataHelper.shared.save()

                seal.fulfill(course)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
