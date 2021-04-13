import PromiseKit
import UserNotifications

final class LocalNotificationsService {
    // MARK: - Getting Notifications -

    /// Returns a list of all notification requests that are scheduled and waiting to be delivered and
    /// a list of the app’s notifications that are still displayed in Notification Center.
    func getAllNotifications() -> Guarantee<(pending: [UNNotificationRequest], delivered: [UNNotification])> {
        Guarantee { seal in
            when(
                fulfilled:
                self.getPendingNotificationRequests(),
                self.getDeliveredNotifications()
            ).done { result in
                seal((pending: result.0, delivered: result.1))
            }.cauterize()
        }
    }

    private func getPendingNotificationRequests() -> Guarantee<[UNNotificationRequest]> {
        Guarantee { seal in
            UNUserNotificationCenter.current().getPendingNotificationRequests { seal($0) }
        }
    }

    private func getDeliveredNotifications() -> Guarantee<[UNNotification]> {
        Guarantee { seal in
            UNUserNotificationCenter.current().getDeliveredNotifications { seal($0) }
        }
    }

    // MARK: - Cancelling Notifications -

    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func removeNotifications(identifiers: [String]) {
        if identifiers.isEmpty {
            return
        }

        self.removePendingNotificationRequests(identifiers: identifiers)
        self.removeDeliveredNotifications(identifiers: identifiers)
    }

    private func removeDeliveredNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private func removePendingNotificationRequests(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Scheduling Notifications -

    func scheduleNotification(_ localNotification: LocalNotificationProtocol) -> Promise<Void> {
        Promise { seal in
            guard let notificationTrigger = localNotification.trigger else {
                throw Error.badContentProvider
            }

            guard self.isFireDateValid(notificationTrigger.nextTriggerDate) else {
                throw Error.badFireDate
            }

            let request = UNNotificationRequest(
                identifier: localNotification.identifier,
                content: self.makeNotificationContent(localNotification: localNotification),
                trigger: notificationTrigger
            )

            UNUserNotificationCenter.current().add(
                request,
                withCompletionHandler: { error in
                    seal.resolve(error)
                }
            )
        }
    }

    func isNotificationExists(identifier: String) -> Guarantee<Bool> {
        Guarantee { seal in
            self.getAllNotifications().done { (pending, delivered) in
                if pending.first(where: { $0.identifier == identifier }) != nil {
                    return seal(true)
                }

                if delivered.first(where: { $0.request.identifier == identifier }) != nil {
                    return seal(true)
                }

                seal(false)
            }
        }
    }

    private func makeNotificationContent(localNotification: LocalNotificationProtocol) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = localNotification.sound

        var userInfo = localNotification.userInfo
        userInfo.merge([
            PayloadKey.notificationName.rawValue: localNotification.identifier,
            PayloadKey.title.rawValue: localNotification.title,
            PayloadKey.body.rawValue: localNotification.body
        ])
        content.userInfo = userInfo

        return content
    }

    /// Checks that `fireDate` is valid.
    ///
    /// - Parameters:
    ///   - fireDate: The Date object to be checked.
    /// - Returns: `true` if the `fireDate` exists and it in the future, otherwise false.
    private func isFireDateValid(_ fireDate: Date?) -> Bool {
        if let fireDate = fireDate {
            return fireDate.compare(Date()) == .orderedDescending
        } else {
            return false
        }
    }

    // MARK: - Types -

    enum PayloadKey: String {
        case notificationName = "LocalNotificationServiceKey"
        case title
        case body
    }

    enum Error: Swift.Error {
        case badContentProvider
        case badFireDate
    }
}
