//
//  LocalNotificationService.swift
//  Stepic
//
//  Created by Ivan Magda on 12/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import UserNotifications
import PromiseKit

final class LocalNotificationService {
    static let shared = LocalNotificationService()

    private static let notificationKeyName = "LocalNotificationServiceKey"

    private init() {
    }

    // MARK: - Getting Notifications -

    /// Returns a list of all currently scheduled local notifications.
    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use getAllNotifications()")
    func getScheduledNotifications() -> [UILocalNotification] {
        return UIApplication.shared.scheduledLocalNotifications ?? []
    }

    /// Returns a list of all notification requests that are scheduled and waiting to be delivered and
    /// a list of the app’s notifications that are still displayed in Notification Center.
    @available(iOS 10.0, *)
    func getAllNotifications() -> Guarantee<(pending: [UNNotificationRequest], delivered: [UNNotification])> {
        return Guarantee { seal in
            var pendingRequests = [UNNotificationRequest]()

            self.getPendingNotificationRequests().then { requests in
                pendingRequests = requests
                return self.getDeliveredNotifications()
            }.done { deliveredNotifications in
                seal((pending: pendingRequests, delivered: deliveredNotifications))
            }
        }
    }

    @available(iOS 10.0, *)
    func getPendingNotificationRequests() -> Guarantee<[UNNotificationRequest]> {
        return Guarantee { seal in
            UNUserNotificationCenter.current().getPendingNotificationRequests {
                seal($0)
            }
        }
    }

    @available(iOS 10.0, *)
    func getDeliveredNotifications() -> Guarantee<[UNNotification]> {
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

    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use removeNotifications(withIdentifiers:)")
    func removeNotification(_ notification: UILocalNotification) {
        UIApplication.shared.cancelLocalNotification(notification)
    }

    func removeNotifications(withIdentifiers identifiers: [String]) {
        guard !identifiers.isEmpty else {
            return
        }

        if #available(iOS 10.0, *) {
            removePendingNotificationRequests(withIdentifiers: identifiers)
            removeDeliveredNotifications(withIdentifiers: identifiers)
        } else {
            let idsSet = Set(identifiers)
            getScheduledNotifications().forEach { notification in
                guard let userInfo = notification.userInfo,
                      let id = userInfo[LocalNotificationService.notificationKeyName] as? String else {
                    return
                }

                if idsSet.contains(id) {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
    }

    @available(iOS 10.0, *)
    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    @available(iOS 10.0, *)
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - Scheduling Notifications -

    func scheduleNotification(contentProvider: LocalNotificationContentProvider) -> Promise<Void> {
        return NotificationPermissionManager().getCurrentPermissionStatus().then { status -> Promise<Void> in
            if status.isAbleSchedule {
                return .value(())
            } else {
                throw LocalNotificationServiceError.notAuthorized
            }
        }.then { _ -> Promise<Void> in
            if #available(iOS 10.0, *) {
                return self.un_scheduleNotification(contentProvider: contentProvider)
            } else {
                return self.ui_scheduleNotification(contentProvider: contentProvider)
            }
        }
    }

    private func isNotificationExists(withIdentifier identifier: String) -> Guarantee<Bool> {
        if #available(iOS 10.0, *) {
            return Guarantee { seal in
                getAllNotifications().done { (pending, delivered) in
                    for request in pending {
                        if request.identifier == identifier {
                            return seal(true)
                        }
                    }

                    for notification in delivered {
                        if notification.request.identifier == identifier {
                            return seal(true)
                        }
                    }

                    seal(false)
                }
            }
        } else {
            return Guarantee { seal in
                let notifications = getScheduledNotifications()

                for notification in notifications {
                    guard let userInfo = notification.userInfo,
                          let key = userInfo[LocalNotificationService.notificationKeyName] as? String else {
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
        var userInfo = contentProvider.userInfo ?? [:]
        userInfo.merge([LocalNotificationService.notificationKeyName: contentProvider.identifier])
        return userInfo
    }

    // MARK: UserNotifications

    @available(iOS 10.0, *)
    private func un_scheduleNotification(
        contentProvider: LocalNotificationContentProvider
    ) -> Promise<Void> {
        return isNotificationExists(withIdentifier: contentProvider.identifier).then { exists -> Promise<UNNotificationRequest> in
            guard !exists else {
                throw LocalNotificationServiceError.notificationAlreadyExists
            }

            guard let notificationTrigger = contentProvider.trigger else {
                throw LocalNotificationServiceError.badContentProvider
            }

            let content = self.makeNotificationContent(for: contentProvider)
            let request = UNNotificationRequest(
                identifier: contentProvider.identifier,
                content: content,
                trigger: notificationTrigger
            )

            return .value(request)
        }.then { notificationRequest -> Guarantee<Error?> in
            Guarantee { seal in
                UNUserNotificationCenter.current().add(
                    notificationRequest,
                    withCompletionHandler: { (error) in
                        seal(error)
                    }
                )
            }
        }.then { requestError -> Promise<Void> in
            if let error = requestError {
                throw error
            } else {
                print("Successfully schedule local notification with identifier: \(contentProvider.identifier)")
                return .value(())
            }
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
        content.userInfo = getMergedUserInfo(contentProvider: contentProvider)

        return content
    }

    // MARK: UILocalNotification

    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use un_scheduleNotification(contentProvider:")
    private func ui_scheduleNotification(
        contentProvider: LocalNotificationContentProvider
    ) -> Promise<Void> {
        return isNotificationExists(withIdentifier: contentProvider.identifier).then { exists -> Promise<UILocalNotification> in
            guard !exists else {
                throw LocalNotificationServiceError.notificationAlreadyExists
            }

            let notification = UILocalNotification()
            notification.alertTitle = contentProvider.title
            notification.alertBody = contentProvider.body
            notification.fireDate = contentProvider.fireDate
            notification.soundName = contentProvider.soundName
            notification.userInfo = self.getMergedUserInfo(contentProvider: contentProvider)

            if let repeatInterval = contentProvider.repeatInterval {
                notification.repeatInterval = repeatInterval
            }

            return .value(notification)
        }.then { notification -> Promise<Void> in
            UIApplication.shared.scheduleLocalNotification(notification)
            return .value(())
        }
    }

    // MARK: - Types -

    enum LocalNotificationServiceError: Error {
        case notAuthorized
        case notificationAlreadyExists
        case badContentProvider
    }
}
