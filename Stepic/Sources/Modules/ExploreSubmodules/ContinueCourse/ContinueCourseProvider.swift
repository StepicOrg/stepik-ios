import Foundation
import PromiseKit

protocol ContinueCourseProviderProtocol {
    func fetchLastCourse() -> Promise<Course?>
}

final class ContinueCourseProvider: ContinueCourseProviderProtocol {
    private let userCoursesNetworkService: UserCoursesNetworkServiceProtocol
    private let coursesNetworkService: CoursesNetworkServiceProtocol
    private let progressesNetworkService: ProgressesNetworkServiceProtocol

    init(
        userCoursesNetworkService: UserCoursesNetworkServiceProtocol,
        coursesNetworkService: CoursesNetworkServiceProtocol,
        progressesNetworkService: ProgressesNetworkServiceProtocol
    ) {
        self.userCoursesNetworkService = userCoursesNetworkService
        self.coursesNetworkService = coursesNetworkService
        self.progressesNetworkService = progressesNetworkService
    }

    func fetchLastCourse() -> Promise<Course?> {
        self.userCoursesNetworkService.fetch().then { userCoursesFetchResult -> Promise<[Course]> in
            let lastCourse = userCoursesFetchResult.0
                .sorted(by: { $0.lastViewed > $1.lastViewed })
                .prefix(1)
            // [] or [id]
            let coursesIDs = lastCourse.compactMap { $0.courseID }
            return self.coursesNetworkService.fetch(ids: coursesIDs)
        }.then { courses -> Promise<(Course?, Progress?)> in
            if let course = courses.first,
               let progressID = course.progressID {
                return self.progressesNetworkService
                    .fetch(id: progressID)
                    .map { (course, $0) }
            } else {
                return .value((nil, nil))
            }
        }.then { course, progress -> Promise<Course?> in
            if let course = course {
                course.progress = progress
                CoreDataHelper.shared.save()
            }

            return .value(course)
        }
    }
}
