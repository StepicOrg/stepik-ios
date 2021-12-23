import Foundation

extension NSNotification.Name {
    static let badgeUpdated = NSNotification.Name("badgeUpdated")
}

@available(*, deprecated, message: "Legacy class")
final class NotificationsBadgesManager {
    static let shared = NotificationsBadgesManager()

    private var badgeValues = Set<Int>()

    private(set) var notificationsCount: Int = 0 {
        didSet {
            NotificationCenter.default.post(
                name: .badgeUpdated,
                object: self,
                userInfo: ["value": self.notificationsCount]
            )
        }
    }

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didNotificationUpdate(systemNotification:)),
            name: .notificationUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didAllNotificationsRead),
            name: .allNotificationsMarkedAsRead,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didNotificationAdd),
            name: .notificationAdded,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setup() {}

    func set(number: Int) {
        if !self.badgeValues.contains(number) {
            self.notificationsCount = number
        } else {
            self.badgeValues.remove(number)
        }
    }

    @objc
    private func didNotificationUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
              let status = userInfo["status"] as? NotificationStatus else {
            return
        }

        if status == .read {
            self.notificationsCount -= 1
            self.badgeValues.insert(self.notificationsCount)
        }
    }

    @objc
    private func didNotificationAdd() {
        self.notificationsCount += 1
        self.badgeValues.insert(self.notificationsCount)
    }

    @objc
    private func didAllNotificationsRead() {
        self.notificationsCount = 0
        self.badgeValues.insert(self.notificationsCount)
    }
}
