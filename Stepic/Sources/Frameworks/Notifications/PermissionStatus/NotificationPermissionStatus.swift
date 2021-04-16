import Foundation
import PromiseKit
import UserNotifications

/// Defines whether the app is allowed to schedule notifications.
enum NotificationPermissionStatus: String {
    /// The user hasn't yet made a choice about whether is allowed the app to schedule notifications.
    case notDetermined
    /// The user not allowed the app to schedule or receive notifications.
    case denied
    /// The user allowed the app to schedule or receive notifications.
    case authorized

    var isRegistered: Bool {
        switch self {
        case .authorized:
            return true
        case .notDetermined, .denied:
            return false
        }
    }

    static var current: Guarantee<NotificationPermissionStatus> {
        Guarantee { seal in
            UNUserNotificationCenter.current().getNotificationSettings {
                seal(NotificationPermissionStatus(authorizationStatus: $0.authorizationStatus))
            }
        }
    }

    init(authorizationStatus: UNAuthorizationStatus) {
        switch authorizationStatus {
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        case .notDetermined:
            self = .notDetermined
        case .provisional:
            self = .authorized
        case .ephemeral:
            self = .notDetermined
        @unknown default:
            self = .notDetermined
        }
    }
}
