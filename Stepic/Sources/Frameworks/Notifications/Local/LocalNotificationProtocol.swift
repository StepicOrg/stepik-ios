import Foundation
import UserNotifications

protocol LocalNotificationProtocol {
    var title: String { get }

    var body: String { get }

    var userInfo: [AnyHashable: Any] { get }

    var identifier: String { get }

    var sound: UNNotificationSound { get }

    var trigger: UNNotificationTrigger? { get }
}

extension LocalNotificationProtocol {
    var userInfo: [AnyHashable: Any] { [:] }

    var sound: UNNotificationSound { .default }
}
