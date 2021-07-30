import Foundation

protocol StreakNotificationsStorageManagerProtocol: AnyObject {
    var isStreakNotificationsEnabled: Bool { get set }
    var streakNotificationsStartHourUTC: Int { get set }
    var streakNotificationsStartHourLocal: Int { get }
}

final class StreakNotificationsStorageManager: StreakNotificationsStorageManagerProtocol {
    var isStreakNotificationsEnabled: Bool {
        get {
            if let storageValue = UserDefaults.standard.value(forKey: Key.allowStreaksNotification.rawValue) as? Bool {
                return storageValue
            } else {
                self.isStreakNotificationsEnabled = false
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.allowStreaksNotification.rawValue)
        }
    }

    var streakNotificationsStartHourUTC: Int {
        get {
            (UserDefaults.standard.value(forKey: Key.streaksNotificationStartHourUTCKey.rawValue) as? Int)
                ?? self.defaultUTCStartHour
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.streaksNotificationStartHourUTCKey.rawValue)
        }
    }

    var streakNotificationsStartHourLocal: Int {
        let time = (self.streakNotificationsStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60) % 24
        return time < 0 ? 24 + time : time
    }

    private var defaultUTCStartHour: Int {
        (24 + 20 - (NSTimeZone.system.secondsFromGMT() / 60 / 60)) % 24
    }

    private enum Key: String {
        case allowStreaksNotification
        case streaksNotificationStartHourUTCKey
    }
}
