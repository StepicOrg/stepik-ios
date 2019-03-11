import Foundation
import PromiseKit

protocol ContinueCourseProviderProtocol {
    func fetchLastCourse() -> Promise<Course?>
}

final class ContinueCourseProvider: ContinueCourseProviderProtocol {
    private let userCoursesAPI: UserCoursesAPI
    private let coursesAPI: CoursesAPI
    private let progressesNetworkService: ProgressesNetworkServiceProtocol

    init(
        userCoursesAPI: UserCoursesAPI,
        coursesAPI: CoursesAPI,
        progressesNetworkService: ProgressesNetworkServiceProtocol
    ) {
        self.userCoursesAPI = userCoursesAPI
        self.coursesAPI = coursesAPI
        self.progressesNetworkService = progressesNetworkService
    }

    func fetchLastCourse() -> Promise<Course?> {
        return Promise { seal in
            self.userCoursesAPI.retrieve(page: 1).then {
                result -> Promise<[Course]> in
                let lastCourse = result.0
                    .sorted(by: { $0.lastViewed > $1.lastViewed })
                    .prefix(1)
                // [] or [id]
                let coursesIDs = lastCourse.compactMap { $0.courseId }
                return self.coursesAPI.retrieve(ids: coursesIDs)
            }.then { courses -> Promise<(Course?, Progress?)> in
                if let course = courses.first,
                   let progressId = course.progressId {
                    return self.progressesNetworkService
                        .fetch(id: progressId)
                        .map { (course, $0) }
                } else {
                    return Promise.value((nil, nil))
                }
            }.done { course, progress in
                course?.progress = progress
                CoreDataHelper.instance.save()
                seal.fulfill(course)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    enum Error: Swift.Error {
        case lastCourseFetchFailed
    }
}
