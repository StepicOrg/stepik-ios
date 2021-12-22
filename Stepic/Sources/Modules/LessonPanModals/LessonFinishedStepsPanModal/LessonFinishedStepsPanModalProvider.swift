import Foundation
import PromiseKit

protocol LessonFinishedStepsPanModalProviderProtocol {
    func fetchCachedCourse() -> Promise<Course?>
    func fetchRemoteCourse() -> Promise<Course?>

    func fetchCachedCourseReview() -> Promise<CourseReview?>
    func fetchRemoteCourseReview() -> Promise<CourseReview?>
}

extension LessonFinishedStepsPanModalProviderProtocol {
    func fetchCourseFromNetworkOrCache() -> Promise<Course?> {
        Guarantee(self.fetchRemoteCourse(), fallback: nil).then { remoteCourseOrNil -> Promise<Course?> in
            if let remoteCourse = remoteCourseOrNil?.flatMap({ $0 }) {
                return .value(remoteCourse)
            } else {
                return self.fetchCachedCourse()
            }
        }
    }

    func fetchCourseReviewFromNetworkOrCache() -> Promise<CourseReview?> {
        Guarantee(
            self.fetchRemoteCourseReview(),
            fallback: nil
        ).then { remoteCourseReviewOrNil -> Promise<CourseReview?> in
            if let remoteCourseReview = remoteCourseReviewOrNil?.flatMap({ $0 }) {
                return .value(remoteCourseReview)
            } else {
                return self.fetchCachedCourseReview()
            }
        }
    }
}

final class LessonFinishedStepsPanModalProvider: LessonFinishedStepsPanModalProviderProtocol {
    private let courseID: Course.IdType

    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol

    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol

    private let certificatesPersistenceService: CertificatesPersistenceServiceProtocol
    private let certificatesNetworkService: CertificatesNetworkServiceProtocol

    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol
    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol

    private let userAccountService: UserAccountServiceProtocol

    init(
        courseID: Course.IdType,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        certificatesPersistenceService: CertificatesPersistenceServiceProtocol,
        certificatesNetworkService: CertificatesNetworkServiceProtocol,
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol,
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.courseID = courseID
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.progressesPersistenceService = progressesPersistenceService
        self.certificatesPersistenceService = certificatesPersistenceService
        self.certificatesNetworkService = certificatesNetworkService
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.courseReviewsNetworkService = courseReviewsNetworkService
        self.userAccountService = userAccountService
    }

    func fetchCachedCourse() -> Promise<Course?> {
        Promise { seal in
            self.fetchAndMergeCourse(
                courseFetchMethod: self.coursesPersistenceService.fetch(id:),
                progressFetchMethod: self.progressesPersistenceService.fetch(id:),
                certificatesFetchMethod: self.fetchCachedCertificates(courseID:userID:)
            ).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemoteCourse() -> Promise<Course?> {
        Promise { seal in
            self.fetchAndMergeCourse(
                courseFetchMethod: self.coursesNetworkService.fetch(id:),
                progressFetchMethod: self.progressesNetworkService.fetch(id:),
                certificatesFetchMethod: self.certificatesNetworkService.fetch(courseID:userID:)
            ).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    func fetchCachedCourseReview() -> Promise<CourseReview?> {
        guard let currentUser = self.userAccountService.currentUser else {
            return .value(nil)
        }

        return Promise { seal in
            self.courseReviewsPersistenceService.fetch(courseID: self.courseID, userID: currentUser.id).done { review in
                review?.user = currentUser
                CoreDataHelper.shared.save()

                seal.fulfill(review)
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemoteCourseReview() -> Promise<CourseReview?> {
        guard let currentUser = self.userAccountService.currentUser else {
            return .value(nil)
        }

        return Promise { seal in
            self.courseReviewsNetworkService.fetch(courseID: self.courseID, userID: currentUser.id).done { reviews, _ in
                let review = reviews.first
                review?.user = currentUser
                CoreDataHelper.shared.save()

                seal.fulfill(review)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    private func fetchAndMergeCourse(
        courseFetchMethod: @escaping (Course.IdType) -> Promise<Course?>,
        progressFetchMethod: @escaping (Progress.IdType) -> Promise<Progress?>,
        certificatesFetchMethod: @escaping (Course.IdType, User.IdType) -> Promise<[Certificate]>
    ) -> Promise<Course?> {
        Promise { seal in
            courseFetchMethod(self.courseID).then { courseOrNil -> Promise<(Course?, Progress?)> in
                if let progressID = courseOrNil?.progressID {
                    return progressFetchMethod(progressID).map { (courseOrNil, $0) }
                }
                return .value((courseOrNil, nil))
            }.then { courseOrNil, progressOrNil -> Promise<(Course?, Progress?, Certificate?)> in
                if courseOrNil?.isWithCertificate ?? false,
                   let currentUserID = self.userAccountService.currentUserID {
                    return certificatesFetchMethod(self.courseID, currentUserID)
                        .map { (courseOrNil, progressOrNil, $0.first) }
                }
                return .value((courseOrNil, progressOrNil, nil))
            }.done { courseOrNil, progressOrNil, certificateOrNil in
                guard let course = courseOrNil else {
                    return seal.fulfill(nil)
                }

                course.progress = progressOrNil
                course.certificateEntity = certificateOrNil

                CoreDataHelper.shared.save()

                seal.fulfill(course)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func fetchCachedCertificates(courseID: Course.IdType, userID: User.IdType) -> Promise<[Certificate]> {
        self.certificatesPersistenceService.fetch(courseID: courseID, userID: userID).then { Promise.value($0) }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
