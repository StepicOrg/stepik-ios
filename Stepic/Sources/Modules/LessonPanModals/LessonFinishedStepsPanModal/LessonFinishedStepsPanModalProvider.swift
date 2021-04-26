import Foundation
import PromiseKit

protocol LessonFinishedStepsPanModalProviderProtocol {
    func fetchCached() -> Promise<Course?>
    func fetchRemote() -> Promise<Course?>
}

extension LessonFinishedStepsPanModalProviderProtocol {
    func fetchFromNetworkOrCache() -> Promise<Course?> {
        self.fetchRemote().then { remoteCourseOrNil -> Promise<Course?> in
            if let remoteCourse = remoteCourseOrNil {
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

    init(
        courseID: Course.IdType,
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        progressesPersistenceService: ProgressesPersistenceServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol
    ) {
        self.courseID = courseID
        self.coursesNetworkService = coursesNetworkService
        self.coursesPersistenceService = coursesPersistenceService
        self.progressesNetworkService = progressesNetworkService
        self.progressesPersistenceService = progressesPersistenceService
    }

    func fetchCached() -> Promise<Course?> {
        Promise { seal in
            self.fetchAndMergeCourse(
                courseFetchMethod: self.coursesPersistenceService.fetch(id:),
                progressFetchMethod: self.progressesPersistenceService.fetch(id:)
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
                progressFetchMethod: self.progressesNetworkService.fetch(id:)
            ).done { course in
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    private func fetchAndMergeCourse(
        courseFetchMethod: @escaping (Course.IdType) -> Promise<Course?>,
        progressFetchMethod: @escaping (Progress.IdType) -> Promise<Progress?>
    ) -> Promise<Course?> {
        Promise { seal in
            courseFetchMethod(self.courseID).then { courseOrNil -> Promise<(Course?, Progress?)> in
                if let progressID = courseOrNil?.progressId {
                    return progressFetchMethod(progressID).map { (courseOrNil, $0) }
                }
                return .value((courseOrNil, nil))
            }.done { courseOrNil, progressOrNil in
                guard let course = courseOrNil else {
                    return seal.fulfill(nil)
                }

                course.progress = progressOrNil
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
