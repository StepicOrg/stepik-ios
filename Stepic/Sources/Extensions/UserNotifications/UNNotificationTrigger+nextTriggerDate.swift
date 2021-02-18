import Foundation
import UserNotifications

extension UNNotificationTrigger {
    var nextTriggerDate: Date? {
        switch self {
        case let timeIntervalTrigger as UNTimeIntervalNotificationTrigger:
            return timeIntervalTrigger.nextTriggerDate()
        case let calendarTrigger as UNCalendarNotificationTrigger:
            return calendarTrigger.nextTriggerDate()
        default:
            return nil
        }
    }
}
