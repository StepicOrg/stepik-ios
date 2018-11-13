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
    private let deepLinkRoutingService: DeepLinkRoutingService

    private var isInForeground: Bool {
        return UIApplication.shared.applicationState == .active
    }

    init(
        localNotificationsService: LocalNotificationsService = LocalNotificationsService(),
        deepLinkRoutingService: DeepLinkRoutingService = DeepLinkRoutingService()
    ) {
        self.localNotificationsService = localNotificationsService
        self.deepLinkRoutingService = deepLinkRoutingService
    }

    func handleLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        NotificationPermissionStatus.current.done { status in
            AnalyticsUserProperties.shared.setPushPermissionStatus(status)
        }

        if let localNotification = launchOptions?[.localNotification] as? UILocalNotification {
            self.handleLocalNotification(with: localNotification.userInfo)
            AmplitudeAnalyticsEvents.Launch.sessionStart(
                notificationType: self.extractNotificationType(from: localNotification.userInfo)
            ).send()
        } else if let userInfo = launchOptions?[.remoteNotification] as? NotificationUserInfo {
            self.handleRemoteNotification(with: userInfo)
            AmplitudeAnalyticsEvents.Launch.sessionStart(
                notificationType: self.extractNotificationType(from: userInfo)
            ).send()
        } else {
            AmplitudeAnalyticsEvents.Launch.sessionStart().send()
        }
    }

    private func extractNotificationType(from userInfo: NotificationUserInfo?) -> String? {
        return userInfo?[PayloadKey.type.rawValue] as? String
    }

    enum NotificationType: String {
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
        if removeIdentical {
            self.removeLocalNotifications(withIdentifiers: [contentProvider.identifier])
        }

        self.localNotificationsService.scheduleNotification(contentProvider: contentProvider).catch { error in
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

    func handleLocalNotification(with userInfo: NotificationUserInfo?) {
        print("Did receive local notification with info: \(userInfo ?? [:])")

        if self.isInForeground, let notificationType = self.extractNotificationType(from: userInfo) {
            AmplitudeAnalyticsEvents.Notifications.received(notificationType: notificationType).send()
        }

        if #available(iOS 10.0, *) {
        } else if self.isInForeground {
            guard let title = userInfo?[LocalNotificationsService.PayloadKey.title.rawValue] as? String,
                  let body = userInfo?[LocalNotificationsService.PayloadKey.body.rawValue] as? String else {
                return
            }

            LegacyNotificationsPresenter.present(text: title, subtitle: body, onTap: {
                self.routeLocalNotification(with: userInfo)
            })
        }
    }

    private func routeLocalNotification(with userInfo: NotificationUserInfo?) {
        func route(to route: DeepLinkRoute) {
            DispatchQueue.main.async {
                self.deepLinkRoutingService.route(route)
            }
        }

        guard let userInfo = userInfo as? [String: Any],
              let key = userInfo[LocalNotificationsService.PayloadKey.notificationName.rawValue] as? String else {
            return route(to: .home)
        }

        if key.localizedCaseInsensitiveContains(NotificationType.streak.rawValue) {
            route(to: .home)
        } else if key.localizedCaseInsensitiveContains(NotificationType.personalDeadline.rawValue) {
            guard let courseId = userInfo[PersonalDeadlineLocalNotificationContentProvider.Key.course.rawValue] as? Int else {
                return route(to: .home)
            }

            route(to: .course(courseID: courseId))
        } else {
            route(to: .home)
        }
    }
}

// MARK: - NotificationsService (RemoteNotifications) -

extension NotificationsService {
    func handleRemoteNotification(with userInfo: NotificationUserInfo) {
        print("remote notification received: DEBUG = \(userInfo)")

        guard let notificationType = self.extractNotificationType(from: userInfo) else {
            return print("remote notification received: unable to parse notification type")
        }

        if self.isInForeground {
            AmplitudeAnalyticsEvents.Notifications.received(notificationType: notificationType).send()
        }

        // FIXME: Use `NotificationType` instead of raw values.
        switch notificationType {
        case NotificationType.notifications.rawValue:
            self.resolveRemoteNotificationsNotification(userInfo)
        case NotificationType.notificationStatuses.rawValue:
            self.resolveRemoteNotificationStatusesNotification(userInfo)
        case NotificationType.achievementProgresses.rawValue:
            self.resolveRemoteAchievementNotification(userInfo)
        default:
            print("remote notification received: unsopported notification type: \(notificationType)")
        }
    }

    private func resolveRemoteNotificationsNotification(_ userInfo: NotificationUserInfo) {
        func postNotification(id: Int, isNew: Bool) {
            NotificationCenter.default.post(
                name: .notificationAdded,
                object: nil,
                userInfo: [PayloadKey.id.rawValue: id, PayloadKey.new.rawValue: isNew]
            )
        }

        guard let aps = userInfo[PayloadKey.aps.rawValue] as? [String: Any],
              let alert = aps[PayloadKey.alert.rawValue] as? [String: Any],
              let body = alert[PayloadKey.body.rawValue] as? String,
              let object = userInfo[PayloadKey.object.rawValue] as? String else {
            return print("remote notification received: unable to parse notification: \(userInfo)")
        }

        var notification: Notification
        let json = JSON(parseJSON: object)

        if let notificationId = json[PayloadKey.id.rawValue].int,
           let fetchedNotification = Notification.fetch(id: notificationId) {
            fetchedNotification.update(json: json)
            notification = fetchedNotification
            postNotification(id: notification.id, isNew: false)
        } else {
            notification = Notification(json: json)
            postNotification(id: notification.id, isNew: true)
        }

        CoreDataHelper.instance.save()

        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                NotificationReactionHandler().handle(with: notification)
            } else if self.isInForeground {
                LegacyNotificationsPresenter.present(text: body, onTap: {
                    NotificationReactionHandler().handle(with: notification)
                })
            } else {
                NotificationReactionHandler().handle(with: notification)
            }
        }
    }

    private func resolveRemoteNotificationStatusesNotification(_ userInfo: NotificationUserInfo) {
        guard let aps = userInfo[PayloadKey.aps.rawValue] as? [String: Any],
              let badge = aps[PayloadKey.badge.rawValue] as? Int else {
            return print("remote notification received: unable to parse notification: \(userInfo)")
        }

        NotificationsBadgesManager.shared.set(number: badge)
    }

    private func resolveRemoteAchievementNotification(_ userInfo: NotificationUserInfo) {
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                TabBarRouter(tab: .profile).route()
            } else if self.isInForeground {
                guard let aps = userInfo[PayloadKey.aps.rawValue] as? [String: Any],
                      let alert = aps[PayloadKey.alert.rawValue] as? [String: Any],
                      let body = alert[PayloadKey.body.rawValue] as? String else {
                    return
                }

                LegacyNotificationsPresenter.present(text: body, onTap: {
                    TabBarRouter(tab: .profile).route()
                })
            } else {
                TabBarRouter(tab: .profile).route()
            }
        }
    }

    enum PayloadKey: String {
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
