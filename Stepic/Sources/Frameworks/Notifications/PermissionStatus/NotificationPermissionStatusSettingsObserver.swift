import Foundation
import PromiseKit

final class NotificationPermissionStatusSettingsObserver {
    private let analytics: Analytics

    private var didTransitionToBackground = false

    init(analytics: Analytics = StepikAnalytics.shared) {
        self.analytics = analytics
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func observe() {
        NotificationPermissionStatus.current.done { permissionStatus in
            let isFirstPermissionAccess = UserDefaults.standard.string(
                forKey: NotificationPermissionStatusSettingsObserver.notificationPermissionStatusKey
            ) == nil
            let isPermissionStatusChanged = self.notificationPermissionStatus != permissionStatus

            if !isFirstPermissionAccess && isPermissionStatusChanged {
                self.reportPreferencesPushPermissionStatusChange(permissionStatus)
            }

            self.notificationPermissionStatus = permissionStatus
            self.addObservers()
        }
    }

    @objc
    private func onWillEnterForeground() {
        NotificationPermissionStatus.current.done { permissionStatus in
            self.updateUserPushPermissionStatusIfNeeded(permissionStatus)

            if self.notificationPermissionStatus != permissionStatus {
                self.reportPreferencesPushPermissionStatusChange(permissionStatus)
            }

            self.didTransitionToBackground = false
            self.notificationPermissionStatus = permissionStatus
        }
    }

    @objc
    private func onDidEnterBackground() {
        self.didTransitionToBackground = true
        NotificationPermissionStatus.current.done { permissionStatus in
            self.notificationPermissionStatus = permissionStatus
        }
    }

    @objc
    private func onPermissionStatusUpdate(_ notification: Foundation.Notification) {
        if let permissionStatus = notification.object as? NotificationPermissionStatus {
            // Wait for `UIApplicationWillEnterForeground` event and after that allow status updates.
            if !self.didTransitionToBackground {
                self.updateUserPushPermissionStatusIfNeeded(permissionStatus)
                self.notificationPermissionStatus = permissionStatus
            }
        }
    }

    private func reportPreferencesPushPermissionStatusChange(_ permissionStatus: NotificationPermissionStatus) {
        self.analytics.send(.notificationsPushPermissionPreferenceChanged(isRegistered: permissionStatus.isRegistered))
    }

    private func updateUserPushPermissionStatusIfNeeded(_ permissionStatus: NotificationPermissionStatus) {
        if self.notificationPermissionStatus != permissionStatus {
            AnalyticsUserProperties.shared.setPushPermissionStatus(permissionStatus)
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onPermissionStatusUpdate(_:)),
            name: .notificationsRegistrationServiceDidUpdatePermissionStatus,
            object: nil
        )
    }
}

// MARK: - NotificationPermissionStatusSettingsObserver (UserDefaults) -

extension NotificationPermissionStatusSettingsObserver {
    private static let notificationPermissionStatusKey = "notificationPermissionStatusKey"

    private var notificationPermissionStatus: NotificationPermissionStatus {
        get {
            if let stringValue = UserDefaults.standard.string(forKey: Self.notificationPermissionStatusKey) {
                return NotificationPermissionStatus(rawValue: stringValue) ?? .notDetermined
            } else {
                return .notDetermined
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Self.notificationPermissionStatusKey)
        }
    }
}
