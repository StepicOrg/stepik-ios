//
//  LocalNotificationsService.swift
//  Stepic
//
//  Created by Ivan Magda on 12/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

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

    func removeNotifications(withIdentifiers identifiers: [String]) {
        if identifiers.isEmpty {
            return
        }

        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Scheduling Notifications -

    func scheduleNotification(contentProvider: LocalNotificationContentProvider) -> Promise<Void> {
        self.userNotificationsScheduleNotification(contentProvider: contentProvider)
    }

    func isNotificationExists(withIdentifier identifier: String) -> Guarantee<Bool> {
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

    private func getMergedUserInfo(
        contentProvider: LocalNotificationContentProvider
    ) -> [AnyHashable: Any] {
        var userInfo = contentProvider.userInfo
        userInfo.merge([
            PayloadKey.notificationName.rawValue: contentProvider.identifier,
            PayloadKey.title.rawValue: contentProvider.title,
            PayloadKey.body.rawValue: contentProvider.body
        ])
        return userInfo
    }

    private func userNotificationsScheduleNotification(
        contentProvider: LocalNotificationContentProvider
    ) -> Promise<Void> {
        Promise { seal in
            guard let notificationTrigger = contentProvider.trigger else {
                throw Error.badContentProvider
            }

            let nextTriggerDate: Date? = {
                switch notificationTrigger {
                case let timeIntervalTrigger as UNTimeIntervalNotificationTrigger:
                    return timeIntervalTrigger.nextTriggerDate()
                case let calendarTrigger as UNCalendarNotificationTrigger:
                    return calendarTrigger.nextTriggerDate()
                default:
                    return nil
                }
            }()

            guard self.isFireDateValid(nextTriggerDate) else {
                throw Error.badFireDate
            }

            let request = UNNotificationRequest(
                identifier: contentProvider.identifier,
                content: self.makeNotificationContent(for: contentProvider),
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

    private func makeNotificationContent(
        for contentProvider: LocalNotificationContentProvider
    ) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = contentProvider.title
        content.body = contentProvider.body
        content.sound = contentProvider.sound
        content.userInfo = self.getMergedUserInfo(contentProvider: contentProvider)

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
