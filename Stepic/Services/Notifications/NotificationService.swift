//
//  NotificationService.swift
//  Stepic
//
//  Created by Ivan Magda on 11/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications
import PromiseKit
import SwiftyJSON

final class NotificationService: NSObject {
    typealias NotificationUserInfo = [AnyHashable: Any]

    static let shared = NotificationService()

    private let localNotificationService: LocalNotificationService
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
        self.localNotificationService = LocalNotificationService()
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
        case personalDeadline
    }
}

// MARK: - NotificationService (LocalNotifications) -

extension NotificationService {
    func scheduleLocalNotification(with contentProvider: LocalNotificationContentProvider) {
        NotificationPermissionManager().getCurrentPermissionStatus().then { status -> Promise<Void> in
            if !status.isRegistered {
                NotificationRegistrator.shared.registerForRemoteNotifications()
            }
            return .value(())
        }.then {
            self.localNotificationService.isNotificationExists(withIdentifier: contentProvider.identifier)
        }.then { isExists -> Promise<Void> in
            if isExists {
                self.removeLocalNotifications(withIdentifiers: [contentProvider.identifier])
            }
            return .value(())
        }.then {
            self.localNotificationService.scheduleNotification(contentProvider: contentProvider)
        }.catch { error in
            print("Failed schedule local notification with error: \(error)")
        }
    }

    func removeLocalNotifications(withIdentifiers identifiers: [String]) {
        guard !identifiers.isEmpty else {
            return
        }

        localNotificationService.removeNotifications(withIdentifiers: identifiers)
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
              let key = userInfo[LocalNotificationService.notificationKeyName] as? String else {
            return routeToHome()
        }

        if key.localizedCaseInsensitiveContains(NotificationTypes.streak.rawValue) {
            routeToHome()
        } else if key.localizedCaseInsensitiveContains(NotificationTypes.personalDeadline.rawValue) {

        } else {
            routeToHome()
        }
    }
}

// MARK: - NotificationService (RemoteNotifications) -

extension NotificationService {
    func didReceiveRemoteNotification(with userInfo: NotificationUserInfo) {
        print("remote notification received: DEBUG = \(userInfo)")

        guard let notificationDict = userInfo as? [String: Any] else {
            print("remote notification received: unable to parse userInfo")
            return
        }

        guard let type = notificationDict["type"] as? String else {
            print("remote notification received: unable to parse notification type")
            return
        }

        switch type {
        case "notifications":
            if let text = ((notificationDict["aps"] as? [String: Any])?["alert"] as? [String: Any])?["body"] as? String {
                var notification: Notification?
                guard let object = notificationDict["object"] as? String else {
                    return
                }

                let json = JSON(parseJSON: object)

                if let notificationId = json["id"].int,
                   let notification = Notification.fetch(id: notificationId) {
                    notification.update(json: json)
                    NotificationCenter.default.post(name: .notificationAdded, object: nil, userInfo: ["id": notification.id, "new": false])
                } else {
                    notification = Notification(json: json)
                    NotificationCenter.default.post(name: .notificationAdded, object: nil, userInfo: ["id": notification!.id, "new": true])
                }

                CoreDataHelper.instance.save()

                NotificationAlertConstructor.sharedConstructor.presentNotificationFake(text, success: { [weak self] in
                    self?.performRemoteReaction(userInfo: userInfo)
                })
            }
        case "notification-statuses":
            if let badgeCount = (notificationDict["aps"] as? [String: Any])?["badge"] as? Int {
                NotificationsBadgesManager.shared.set(number: badgeCount)
            }
        default:
            break
        }
    }

    private func performRemoteReaction(userInfo: NotificationUserInfo) {
        guard let reaction = NotificationReactionHandler.handle(with: userInfo),
              let topController = self.currentNavigationController?.topViewController else {
            return
        }

        reaction(topController)
    }
}

// MARK: - NotificationService: UNUserNotificationCenterDelegate -

@available(iOS 10.0, *)
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }
}
