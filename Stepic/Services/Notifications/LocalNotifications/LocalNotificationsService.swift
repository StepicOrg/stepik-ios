//
//  LocalNotificationsService.swift
//  Stepic
//
//  Created by Ivan Magda on 12/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import UserNotifications
import PromiseKit

final class LocalNotificationsService {
    // MARK: - Getting Notifications -

    /// Returns a list of all currently scheduled local notifications.
    func getScheduledNotifications() -> [UILocalNotification] {
        return UIApplication.shared.scheduledLocalNotifications ?? []
    }

    /// Returns a list of all notification requests that are scheduled and waiting to be delivered and
    /// a list of the app’s notifications that are still displayed in Notification Center.
    @available(iOS 10.0, *)
    func getAllNotifications() -> Guarantee<(pending: [UNNotificationRequest], delivered: [UNNotification])> {
        return Guarantee { seal in
            when(fulfilled: self.getPendingNotificationRequests(), self.getDeliveredNotifications()).done { result in
                seal((pending: result.0, delivered: result.1))
            }.cauterize()
        }
    }

    @available(iOS 10.0, *)
    private func getPendingNotificationRequests() -> Guarantee<[UNNotificationRequest]> {
        return Guarantee { seal in
            UNUserNotificationCenter.current().getPendingNotificationRequests {
                seal($0)
            }
        }
    }

    @available(iOS 10.0, *)
    private func getDeliveredNotifications() -> Guarantee<[UNNotification]> {
        return Guarantee { seal in
            UNUserNotificationCenter.current().getDeliveredNotifications {
                seal($0)
            }
        }
    }

    // MARK: - Cancelling Notifications -

    func removeAllNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }

    func removeNotifications(withIdentifiers identifiers: [String]) {
        if identifiers.isEmpty {
            return
        }

        if #available(iOS 10.0, *) {
            self.removePendingNotificationRequests(withIdentifiers: identifiers)
            self.removeDeliveredNotifications(withIdentifiers: identifiers)
        } else {
            let idsSet = Set(identifiers)
            self.getScheduledNotifications().forEach { notification in
                guard let userInfo = notification.userInfo,
                      let id = userInfo[PayloadKey.notificationName.rawValue] as? String else {
                    return
                }

                if idsSet.contains(id) {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
    }

    @available(iOS 10.0, *)
    private func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    @available(iOS 10.0, *)
    private func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Scheduling Notifications -

    func scheduleNotification(contentProvider: LocalNotificationContentProvider) -> Promise<Void> {
        if #available(iOS 10.0, *) {
            return self.userNotificationsScheduleNotification(contentProvider: contentProvider)
        } else {
            return self.localNotificationScheduleNotification(contentProvider: contentProvider)
        }
    }

    func isNotificationExists(withIdentifier identifier: String) -> Guarantee<Bool> {
        if #available(iOS 10.0, *) {
            return Guarantee { seal in
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
        } else {
            return Guarantee { seal in
                for notification in self.getScheduledNotifications() {
                    guard let userInfo = notification.userInfo,
                          let key = userInfo[PayloadKey.notificationName.rawValue] as? String else {
                        continue
                    }

                    if key == identifier {
                        return seal(true)
                    }
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

    @available(iOS 10.0, *)
    private func userNotificationsScheduleNotification(
        contentProvider: LocalNotificationContentProvider
    ) -> Promise<Void> {
        return Promise { seal in
            guard let notificationTrigger = contentProvider.trigger else {
                throw Error.badContentProvider
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

    @available(iOS 10.0, *)
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

    private func localNotificationScheduleNotification(
        contentProvider: LocalNotificationContentProvider
    ) -> Promise<Void> {
        let notification = UILocalNotification()
        notification.alertTitle = contentProvider.title
        notification.alertBody = contentProvider.body
        notification.fireDate = contentProvider.fireDate
        notification.soundName = contentProvider.soundName
        notification.userInfo = self.getMergedUserInfo(contentProvider: contentProvider)

        if let repeatInterval = contentProvider.repeatInterval {
            notification.repeatInterval = repeatInterval
        }

        UIApplication.shared.scheduleLocalNotification(notification)

        return .value(())
    }

    // MARK: - Types -

    enum PayloadKey: String {
        case notificationName = "LocalNotificationServiceKey"
        case title
        case body
    }

    enum Error: Swift.Error {
        case badContentProvider
    }
}
