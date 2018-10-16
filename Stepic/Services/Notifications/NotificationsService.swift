//
//  NotificationsService.swift
//  Stepic
//
//  Created by Ivan Magda on 11/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications
import PromiseKit
import SwiftyJSON

final class NotificationsService {
    typealias NotificationUserInfo = [AnyHashable: Any]

    private let localNotificationsService: LocalNotificationsService
    private let routingService: DeepLinkRoutingService

    private var isInForeground: Bool {
        return UIApplication.shared.applicationState == .active
    }

    init(
        localNotificationsService: LocalNotificationsService = LocalNotificationsService(),
        deepLinkRoutingService: DeepLinkRoutingService = DeepLinkRoutingService()
    ) {
        self.localNotificationsService = localNotificationsService
        self.routingService = deepLinkRoutingService
    }

    func appDidFinishLaunching(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if launchOptions?[.localNotification] != nil {
            let notification = launchOptions?[.localNotification] as? UILocalNotification
            self.didReceiveLocalNotification(with: notification?.userInfo)
            AmplitudeAnalyticsEvents.Launch.sessionStart(
                notificationType: notification?.userInfo?.notificationType
            ).send()
        } else if let userInfo = launchOptions?[.remoteNotification] as? NotificationUserInfo {
            self.didReceiveRemoteNotification(with: userInfo)
            AmplitudeAnalyticsEvents.Launch.sessionStart(
                notificationType: userInfo.notificationType
            ).send()
        } else {
            AmplitudeAnalyticsEvents.Launch.sessionStart().send()
        }
    }

    enum NotificationTypes: String {
        case streak
        case personalDeadline = "personal-deadline"
        case notifications
        case notificationStatuses = "notification-statuses"
        case achievementProgresses = "achievement-progresses"
    }
}

// MARK: - NotificationsService (LocalNotifications) -

extension NotificationsService {
    func scheduleLocalNotification(
        with contentProvider: LocalNotificationContentProvider,
        removeIdentical: Bool = true
    ) {
        NotificationPermissionManager().getCurrentPermissionStatus().then { status -> Promise<Void> in
            if !status.isRegistered {
                NotificationRegistrator.shared.registerForRemoteNotifications()
            }

            if removeIdentical {
                self.removeLocalNotifications(withIdentifiers: [contentProvider.identifier])
            }

            return self.localNotificationsService.scheduleNotification(contentProvider: contentProvider)
        }.catch { error in
            print("Failed schedule local notification with error: \(error)")
        }
    }

    func removeAllLocalNotifications() {
        self.localNotificationsService.removeAllNotifications()
    }

    func removeLocalNotifications(withIdentifiers identifiers: [String]) {
        if !identifiers.isEmpty {
            self.localNotificationsService.removeNotifications(withIdentifiers: identifiers)
        }
    }

    func didReceiveLocalNotification(with userInfo: NotificationUserInfo?) {
        print("Did receive local notification with info: \(userInfo ?? [:])")

        if self.isInForeground, let notificationType = userInfo?.notificationType {
            AmplitudeAnalyticsEvents.Notifications.received(notificationType: notificationType).send()
        }

        self.routeLocalNotification(with: userInfo)
    }

    private func routeLocalNotification(with userInfo: NotificationUserInfo?) {
        func routeToHome() {
            self.routingService.route(.home)
        }

        guard let userInfo = userInfo as? [String: Any],
              let key = userInfo[LocalNotificationsService.notificationKeyName] as? String else {
            return routeToHome()
        }

        if key.localizedCaseInsensitiveContains(NotificationTypes.streak.rawValue) {
            routeToHome()
        } else if key.localizedCaseInsensitiveContains(NotificationTypes.personalDeadline.rawValue) {
            guard let courseId = userInfo[PersonalDeadlineLocalNotificationContentProvider.Keys.course.rawValue] as? Int else {
                return routeToHome()
            }

            self.routingService.route(.course(courseID: courseId))
        } else {
            routeToHome()
        }
    }
}

// MARK: - NotificationsService (RemoteNotifications) -

extension NotificationsService {
    func didReceiveRemoteNotification(with userInfo: NotificationUserInfo) {
        print("remote notification received: DEBUG = \(userInfo)")

        guard let type = userInfo.notificationType else {
            return print("remote notification received: unable to parse notification type")
        }

        if self.isInForeground {
            AmplitudeAnalyticsEvents.Notifications.received(notificationType: type).send()
        }

        guard let notification = userInfo as? [String: Any] else {
            return print("remote notification received: unable to parse userInfo")
        }

        switch type {
        case NotificationTypes.notifications.rawValue:
            resolveRemoteNotificationsNotification(notification)
        case NotificationTypes.notificationStatuses.rawValue:
            resolveRemoteNotificationStatusesNotification(notification)
        case NotificationTypes.achievementProgresses.rawValue:
            resolveRemoteAchievementNotification(notification)
        default:
            print("remote notification received: unsopported notification type: \(type)")
        }
    }

    private func resolveRemoteNotificationsNotification(_ notificationDict: [String: Any]) {
        func postNotification(id: Int, isNew: Bool) {
            NotificationCenter.default.post(
                name: .notificationAdded,
                object: nil,
                userInfo: [Keys.id.rawValue: id, Keys.new.rawValue: isNew]
            )
        }

        guard let aps = notificationDict[Keys.aps.rawValue] as? [String: Any],
              let alert = aps[Keys.alert.rawValue]  as? [String: Any],
              let body = alert[Keys.body.rawValue] as? String,
              let object = notificationDict[Keys.object.rawValue] as? String else {
            return print("remote notification received: unable to parse notification: \(notificationDict)")
        }

        var notification: Notification
        let json = JSON(parseJSON: object)

        if let notificationId = json[Keys.id.rawValue].int,
           let fetchedNotification = Notification.fetch(id: notificationId) {
            fetchedNotification.update(json: json)
            notification = fetchedNotification
            postNotification(id: notification.id, isNew: false)
        } else {
            notification = Notification(json: json)
            postNotification(id: notification.id, isNew: true)
        }

        CoreDataHelper.instance.save()

        // Show alert for iOS 9.0 when the application is in foreground state.
        if #available(iOS 10.0, *) {
            NotificationReactionHandler().handle(with: notification)
        } else if self.isInForeground {
            NotificationAlertConstructor.sharedConstructor.presentNotificationFake(body, success: {
                NotificationReactionHandler().handle(with: notification)
            })
        } else {
            NotificationReactionHandler().handle(with: notification)
        }
    }

    private func resolveRemoteNotificationStatusesNotification(_ notificationDict: [String: Any]) {
        guard let aps = notificationDict[Keys.aps.rawValue] as? [String: Any],
              let badge = aps[Keys.badge.rawValue] as? Int else {
            return print("remote notification received: unable to parse notification: \(notificationDict)")
        }

        NotificationsBadgesManager.shared.set(number: badge)
    }

    private func resolveRemoteAchievementNotification(_ notificationDict: [String: Any]) {
        TabBarRouter(tab: .profile).route()
    }

    enum Keys: String {
        case type
        case aps
        case alert
        case body
        case object
        case id
        case new
        case badge
    }
}

private extension Dictionary where Key == AnyHashable {
    var notificationType: String? {
        return self[NotificationsService.Keys.type.rawValue] as? String
    }
}
