import Foundation
import UserNotifications

struct StreakLocalNotification: LocalNotificationProtocol {
    let utcStartHour: Int

    var title = ""

    var body: String {
        NSString.localizedUserNotificationString(forKey: "StreakNotificationAlertBody", arguments: nil)
    }

    var userInfo: [AnyHashable: Any] {
        [NotificationsService.PayloadKey.type.rawValue: NotificationsService.NotificationType.streak.rawValue]
    }

    var identifier: String { "\(NotificationsService.NotificationType.streak.rawValue)_local_notification" }

    var sound: UNNotificationSound {
        UNNotificationSound(named: UNNotificationSoundName("default_sound.wav"))
    }

    var trigger: UNNotificationTrigger? {
        UNCalendarNotificationTrigger(dateMatching: self.dateComponents, repeats: true)
    }

    private var dateComponents: DateComponents {
        let timeZoneDiff = NSTimeZone.system.secondsFromGMT() / 3600
        var localStartHour = self.utcStartHour + timeZoneDiff

        if localStartHour < 0 {
            localStartHour += 24
        }

        if localStartHour > 23 {
            localStartHour -= 24
        }

        return DateComponents(hour: localStartHour)
    }
}

// MARK: - NotificationsService (StreakLocalNotification) -

extension NotificationsService {
    func scheduleStreakLocalNotification(utcStartHour: Int) {
        let notification = StreakLocalNotification(utcStartHour: utcStartHour)
        self.scheduleLocalNotification(notification)
    }

    func removeStreakLocalNotifications() {
        let notification = StreakLocalNotification(utcStartHour: 0)
        self.removeLocalNotifications(identifiers: [notification.identifier])
    }
}
