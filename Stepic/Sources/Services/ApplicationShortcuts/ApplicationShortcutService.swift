import PromiseKit
import SVProgressHUD
import UIKit

protocol ApplicationShortcutServiceProtocol: AnyObject {
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool
    func handleLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
}

final class ApplicationShortcutService: ApplicationShortcutServiceProtocol {
    private let lastCourseDataShortcutService: LastCourseDataShortcutServiceProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol

    private let userAccountService: UserAccountServiceProtocol

    private let sourcelessRouter: SourcelessRouter

    private let analytics: Analytics

    init(
        lastCourseDataShortcutService: LastCourseDataShortcutServiceProtocol = LastCourseDataShortcutService(),
        adaptiveStorageManager: AdaptiveStorageManagerProtocol = AdaptiveStorageManager(),
        userAccountService: UserAccountServiceProtocol = UserAccountService(),
        sourcelessRouter: SourcelessRouter = SourcelessRouter(),
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.lastCourseDataShortcutService = lastCourseDataShortcutService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.userAccountService = userAccountService
        self.sourcelessRouter = sourcelessRouter
        self.analytics = analytics
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

        self.analytics.send(.applicationShortcutItemTriggered(type: shortcutType))

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
        case .searchCourses:
            TabBarRouter(tab: .catalog(searchCourses: true)).route()
        case .profile:
            TabBarRouter(tab: .profile).route()
        case .notifications:
            TabBarRouter(tab: .notifications).route()
        }
    }

    private func performContinueLearning() {
        guard self.userAccountService.isAuthorized else {
            return SVProgressHUD.showError(
                withStatus: NSLocalizedString("QuickActionContinueLearningErrorUnauthorizedMessage", comment: "")
            )
        }

        self.lastCourseDataShortcutService.fetchLastCourse().done { lastCourse in
            guard let lastCourse = lastCourse,
                  let currentNavigationController = self.sourcelessRouter.currentNavigation else {
                throw Error.noLastCourse
            }

            LastStepRouter.continueLearning(
                for: lastCourse,
                isAdaptive: self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: lastCourse.id),
                using: currentNavigationController,
                source: .applicationShortcut,
                viewSource: .unknown
            )
        }.catch { error in
            print("ApplicationShortcutService :: failed perform continue learning with error = \(error)")
            SVProgressHUD.showError(
                withStatus: NSLocalizedString("QuickActionContinueLearningErrorMessage", comment: "")
            )
        }
    }

    // MARK: Enum

    enum Error: Swift.Error {
        case noLastCourse
    }
}
