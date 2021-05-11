import Foundation
import PromiseKit

protocol LessonFinishedStepsPanModalProviderProtocol {
    func fetchCached() -> Promise<Course?>
    func fetchRemote() -> Promise<Course?>
}

extension LessonFinishedStepsPanModalProviderProtocol {
    func fetchFromNetworkOrCache() -> Promise<Course?> {
        Guarantee(self.fetchRemote(), fallback: nil).then { remoteCourseOrNil -> Promise<Course?> in
            if let remoteCourse = remoteCourseOrNil?.flatMap({ $0 }) {
                return .value(remoteCourse)
            } else {
                return self.fetchCached()
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

    private let userAccountService: UserAccountServiceProtocol

    init(
        courseID: Course.IdType,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol,
        certificatesPersistenceService: CertificatesPersistenceServiceProtocol,
        certificatesNetworkService: CertificatesNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.courseID = courseID
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.progressesPersistenceService = progressesPersistenceService
        self.certificatesPersistenceService = certificatesPersistenceService
        self.certificatesNetworkService = certificatesNetworkService
        self.userAccountService = userAccountService
    }

    func fetchCached() -> Promise<Course?> {
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

    func fetchRemote() -> Promise<Course?> {
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

    private func fetchAndMergeCourse(
        courseFetchMethod: @escaping (Course.IdType) -> Promise<Course?>,
        progressFetchMethod: @escaping (Progress.IdType) -> Promise<Progress?>,
        certificatesFetchMethod: @escaping (Course.IdType, User.IdType) -> Promise<[Certificate]>
    ) -> Promise<Course?> {
        Promise { seal in
            courseFetchMethod(self.courseID).then { courseOrNil -> Promise<(Course?, Progress?)> in
                if let progressID = courseOrNil?.progressId {
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
