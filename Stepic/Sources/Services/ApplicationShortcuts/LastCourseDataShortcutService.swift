import Foundation
import PromiseKit

protocol LastCourseDataShortcutServiceProtocol: AnyObject {
    func fetchLastCourse() -> Promise<Course?>
}

final class LastCourseDataShortcutService: LastCourseDataShortcutServiceProtocol {
    private let userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let continueCourseProvider: ContinueCourseProviderProtocol

    init(
        userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol = UserCoursesPersistenceService(),
        coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService(),
        adaptiveStorageManager: AdaptiveStorageManagerProtocol = AdaptiveStorageManager(),
        continueCourseProvider: ContinueCourseProviderProtocol = ContinueCourseProvider(
            userCoursesNetworkService: UserCoursesNetworkService(userCoursesAPI: UserCoursesAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
    ) {
        self.userCoursesPersistenceService = userCoursesPersistenceService
        self.coursesPersistenceService = coursesPersistenceService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.continueCourseProvider = continueCourseProvider
    }

    func fetchLastCourse() -> Promise<Course?> {
        self.userCoursesPersistenceService.fetchAll().then { userCourses -> Promise<([UserCourse], [Course])> in
            self.coursesPersistenceService
                .fetch(ids: userCourses.map(\.courseID))
                .map { (userCourses, $0.0) }
        }.then { cachedUserCourses, cachedCourses -> Promise<Course?> in
            let lastUserCourse = cachedUserCourses.filter { userCourse in
                cachedCourses.contains(where: { $0.id == userCourse.courseID && $0.enrolled })
            }.max(by: { $0.lastViewed < $1.lastViewed })

            if let lastUserCourse = lastUserCourse,
               let lastCourse = cachedCourses.first(where: { $0.id == lastUserCourse.courseID }) {
                return .value(lastCourse)
            }

            return self.continueCourseProvider.fetchLastCourse()
        }
    }
}
