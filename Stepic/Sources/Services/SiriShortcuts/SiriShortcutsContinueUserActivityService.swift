import Foundation
import PromiseKit
import SVProgressHUD

@available(iOS 12.0, *)
protocol SiriShortcutsContinueUserActivityServiceProtocol: AnyObject {
    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool
}

@available(iOS 12.0, *)
final class SiriShortcutsContinueUserActivityService: SiriShortcutsContinueUserActivityServiceProtocol {
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

    func continueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivity.continueLearningActivityType else {
            return false
        }

        self.analytics.send(.siriShortcutContinued(type: .continueLearning))

        DispatchQueue.main.async {
            self.performContinueLearning()
        }

        return true
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
                source: .siriShortcut,
                viewSource: .unknown
            )
        }.catch { error in
            print("SiriShortcutsContinueUserActivityService :: failed perform continue learning with error = \(error)")
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
