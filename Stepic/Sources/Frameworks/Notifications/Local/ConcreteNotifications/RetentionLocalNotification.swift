import Foundation
import UserNotifications

struct RetentionLocalNotification: LocalNotificationProtocol {
    private static let defaultRetentionHour = 17
    private static let retentionHoursRange = (12...19)

    let retention: RetentionType

    var title: String { self.retention.notificationTitle }

    var body: String { self.retention.notificationText }

    var userInfo: [AnyHashable: Any] {
        [
            NotificationsService.PayloadKey.type.rawValue: self.retention.notificationType
        ]
    }

    var identifier: String { "RetentionLocalNotification_\(self.retention.rawValue)" }

    var trigger: UNNotificationTrigger? {
        guard let dateComponents = self.dateComponents else {
            return nil
        }

        switch self.retention {
        case .nextDay:
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        case .thirdDay:
            let timeInterval: TimeInterval

            if let date = Calendar.current.date(from: dateComponents) {
                timeInterval = date.timeIntervalSince(Date())
            } else {
                timeInterval = 3 * 24 * 60 * 60
            }

            return UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        }
    }

    private var dateComponents: DateComponents? {
        guard let date = Calendar.current.date(
            byAdding: .day,
            value: self.retention.notificationDayOffset,
            to: Date()
        ) else {
            return nil
        }

        var retentionDateComponents = Calendar.current.dateComponents([.hour, .day, .month, .year], from: date)
        var retentionHour = retentionDateComponents.hour ?? Self.defaultRetentionHour

        if !Self.retentionHoursRange.contains(retentionHour) {
            retentionHour = Self.defaultRetentionHour
        }

        retentionDateComponents.hour = retentionHour

        return retentionDateComponents
    }

    enum RetentionType: String {
        case nextDay
        case thirdDay

        fileprivate var notificationType: String {
            switch self {
            case .nextDay:
                return NotificationsService.NotificationType.retentionNextDay.rawValue
            case .thirdDay:
                return NotificationsService.NotificationType.retentionThirdDay.rawValue
            }
        }

        fileprivate var notificationTitle: String {
            switch self {
            case .nextDay:
                return NSString.localizedUserNotificationString(
                    forKey: "RetentionNotificationOnNextDayTitle",
                    arguments: nil
                )
            case .thirdDay:
                return NSString.localizedUserNotificationString(
                    forKey: "RetentionNotificationOnThirdDayTitle",
                    arguments: nil
                )
            }
        }

        fileprivate var notificationText: String {
            switch self {
            case .nextDay:
                return NSString.localizedUserNotificationString(
                    forKey: "RetentionNotificationOnNextDayText",
                    arguments: nil
                )
            case .thirdDay:
                return NSString.localizedUserNotificationString(
                    forKey: "RetentionNotificationOnThirdDayText",
                    arguments: nil
                )
            }
        }

        fileprivate var notificationDayOffset: Int {
            switch self {
            case .nextDay:
                return 1
            case .thirdDay:
                return 3
            }
        }
    }
}

// MARK: - NotificationsService (RetentionLocalNotification) -

extension NotificationsService {
    private var retentionLocalNotifications: [RetentionLocalNotification] {
        [
            RetentionLocalNotification(retention: .nextDay),
            RetentionLocalNotification(retention: .thirdDay)
        ]
    }

    func scheduleRetentionLocalNotifications() {
        if !PreferencesContainer.notifications.allowStreaksNotifications {
            self.retentionLocalNotifications.forEach { notification in
                self.scheduleLocalNotification(notification)
            }
        }
    }

    func removeRetentionLocalNotifications() {
        let ids = self.retentionLocalNotifications.map(\.identifier)
        self.removeLocalNotifications(identifiers: ids)
    }
}
