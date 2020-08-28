import PromiseKit
import UIKit

protocol ApplicationShortcutServiceProtocol: AnyObject {
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool
    func handleLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
}

final class ApplicationShortcutService: ApplicationShortcutServiceProtocol {
    private let userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let continueCourseProvider: ContinueCourseProviderProtocol

    private let sourcelessRouter: SourcelessRouter

    private var currentNavigationController: UINavigationController? {
        self.sourcelessRouter.currentNavigation
    }

    init(
        userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol = UserCoursesPersistenceService(),
        coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService(),
        adaptiveStorageManager: AdaptiveStorageManagerProtocol = AdaptiveStorageManager(),
        continueCourseProvider: ContinueCourseProviderProtocol = ContinueCourseProvider(
            userCoursesAPI: UserCoursesAPI(),
            coursesAPI: CoursesAPI(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        ),
        sourcelessRouter: SourcelessRouter = SourcelessRouter()
    ) {
        self.userCoursesPersistenceService = userCoursesPersistenceService
        self.coursesPersistenceService = coursesPersistenceService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.continueCourseProvider = continueCourseProvider
        self.sourcelessRouter = sourcelessRouter
    }

    // MARK: Protocol Conforming

    func handleLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            _ = self.handleShortcutItem(shortcutItem)
            return true
        }
        return false
    }

    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type

        guard let shortcutIdentifier = ApplicationShortcutIdentifier(fullIdentifier: shortcutType) else {
            return false
        }

        DispatchQueue.main.async {
            self.performActionFor(shortcutIdentifier)
        }

        return true
    }

    // MARK: Private API

    private func performActionFor(_ shortcutIdentifier: ApplicationShortcutIdentifier) {
        switch shortcutIdentifier {
        case .continueLearning:
            self.performContinueLearning()
        }
    }

    private func performContinueLearning() {
        self.userCoursesPersistenceService.fetchAll().then { userCourses -> Promise<([UserCourse], [Course])> in
            self.coursesPersistenceService
                .fetch(ids: userCourses.map(\.courseID))
                .map { (userCourses, $0.0) }
        }.then { cachedUserCourses, cachedCourses -> Promise<Course?> in
            let lastUserCourse = cachedUserCourses.filter { userCourse in
                cachedCourses.contains(where: { $0.id == userCourse.courseID })
            }.max(by: { $0.lastViewed < $1.lastViewed })

            if let lastUserCourse = lastUserCourse,
               let lastCourse = cachedCourses.first(where: { $0.id == lastUserCourse.courseID }) {
                return .value(lastCourse)
            }

            return self.continueCourseProvider.fetchLastCourse()
        }.done { lastCourse in
            guard let lastCourse = lastCourse,
                  let currentNavigationController = self.currentNavigationController else {
                return
            }

            LastStepRouter.continueLearning(
                for: lastCourse,
                isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: lastCourse.id),
                using: currentNavigationController,
                courseViewSource: .unknown
            )
        }.catch { error in
            print("ApplicationShortcutService :: failed perform continue learning with error = \(error)")
        }
    }
}
