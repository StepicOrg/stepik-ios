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

final class NotificationsService: NSObject {
    typealias NotificationUserInfo = [AnyHashable: Any]

    static let shared = NotificationsService()

    private let localNotificationsService: LocalNotificationsService
    private let routingService: DeepLinkRoutingService

    private var currentNavigationController: UINavigationController? {
        guard let window = UIApplication.shared.delegate?.window,
              let tabController = window?.rootViewController as? UITabBarController else {
            return nil
        }

        let countViewControllers = tabController.viewControllers?.count ?? 0

        if tabController.selectedIndex < countViewControllers {
            return tabController.viewControllers?[tabController.selectedIndex] as? UINavigationController
        } else {
            return tabController.viewControllers?[0] as? UINavigationController
        }
    }

    private override init() {
        self.localNotificationsService = LocalNotificationsService()
        self.routingService = DeepLinkRoutingService()

        super.init()

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }

    func appDidFinishLaunching(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions else {
            return
        }

        if launchOptions[.localNotification] != nil {
            let notification = launchOptions[.localNotification] as? UILocalNotification
            didReceiveLocalNotification(with: notification?.userInfo)
        } else if let userInfo = launchOptions[.remoteNotification] as? NotificationUserInfo {
            didReceiveRemoteNotification(with: userInfo)
        }
    }

    enum NotificationTypes: String {
        case streak
        case personalDeadline = "personaldeadline"
        case notifications
        case notificationStatuses = "notification-statuses"
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
            return .value(())
        }.then { _ -> Promise<Void> in
            if removeIdentical {
                self.removeLocalNotifications(withIdentifiers: [contentProvider.identifier])
            }

            return .value(())
        }.then {
            self.localNotificationsService.scheduleNotification(contentProvider: contentProvider)
        }.catch { error in
            print("Failed schedule local notification with error: \(error)")
        }
    }

    func removeAllLocalNotifications() {
        localNotificationsService.removeAllNotifications()
    }

    func removeLocalNotifications(withIdentifiers identifiers: [String]) {
        guard !identifiers.isEmpty else {
            return
        }

        localNotificationsService.removeNotifications(withIdentifiers: identifiers)
    }

    func didReceiveLocalNotification(with userInfo: NotificationUserInfo?) {
        print("Did receive local notification with info: \(userInfo ?? [:])")
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notificationOpened)
        routeLocalNotification(with: userInfo)
    }

    private func routeLocalNotification(with userInfo: NotificationUserInfo?) {
        func routeToHome() {
            routingService.route(.home)
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

            routingService.route(DeepLinkRoutingService.Route.course(courseID: courseId))
        } else {
            routeToHome()
        }
    }
}

// MARK: - NotificationsService (RemoteNotifications) -

extension NotificationsService {
    func didReceiveRemoteNotification(with userInfo: NotificationUserInfo) {
        //print("remote notification received: DEBUG = \(userInfo)")

        logJSONString(userInfo: userInfo)

        guard let notification = userInfo as? [String: Any] else {
            return print("remote notification received: unable to parse userInfo")
        }

        guard let type = notification[Keys.type.rawValue] as? String else {
            return print("remote notification received: unable to parse notification type")
        }

        switch type {
        case NotificationTypes.notifications.rawValue:
            resolveRemoteNotificationsNotification(notification)
        case NotificationTypes.notificationStatuses.rawValue:
            resolveRemoteNotificationStatusesNotification(notification)
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

        let json = JSON(parseJSON: object)

        if let notificationId = json[Keys.id.rawValue].int,
           let notification = Notification.fetch(id: notificationId) {
            notification.update(json: json)
            postNotification(id: notification.id, isNew: false)
        } else {
            let notification = Notification(json: json)
            postNotification(id: notification.id, isNew: true)
        }

        CoreDataHelper.instance.save()

        // Show alert for iOS 9.0 when the application is in foreground state.
        if #available(iOS 10.0, *) {
            routeRemoteNotification(notificationDict)
        } else if UIApplication.shared.applicationState == .active {
            NotificationAlertConstructor.sharedConstructor.presentNotificationFake(body, success: { [weak self] in
                self?.routeRemoteNotification(notificationDict)
            })
        } else {
            routeRemoteNotification(notificationDict)
        }
    }

    private func resolveRemoteNotificationStatusesNotification(_ notificationDict: [String: Any]) {
        guard let aps = notificationDict[Keys.aps.rawValue] as? [String: Any],
              let badge = aps[Keys.badge.rawValue] as? Int else {
            return print("remote notification received: unable to parse notification: \(notificationDict)")
        }

        NotificationsBadgesManager.shared.set(number: badge)
    }

    private func routeRemoteNotification(_ notification: NotificationUserInfo) {
        guard let reaction = NotificationReactionHandler.handle(with: notification),
              let topController = self.currentNavigationController?.topViewController else {
            return
        }

        reaction(topController)
    }

    private func logJSONString(userInfo: NotificationUserInfo) {
        let theJSONData = try! JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let theJSONText = String(data: theJSONData, encoding: .ascii)!
        print("\n\n")
        print(theJSONText)
        print("\n\n")
    }

    private enum Keys: String {
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

// MARK: - NotificationsService: UNUserNotificationCenterDelegate -

@available(iOS 10.0, *)
extension NotificationsService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }
}
