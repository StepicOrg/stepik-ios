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

    let localNotificationService: LocalNotificationService

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
        super.init()

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }

    // MARK: Public API

    func appDidFinishLaunching(with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions else {
            return
        }

        let localNotification = launchOptions[.localNotification] as? UILocalNotification
        let localNotification2 = launchOptions[.localNotification] as? NotificationUserInfo
        let localNotification3 = launchOptions[.localNotification] as? NSDictionary
        let localNotification4 = launchOptions[.localNotification]

        if launchOptions[.localNotification] != nil {
            didReceiveLocalNotification(with: nil)
        } else if let userInfo = launchOptions[.remoteNotification] as? NotificationUserInfo {
            didReceiveRemoteNotification(with: userInfo)
        }
    }

    func didReceiveLocalNotification(with userInfo: NotificationUserInfo?) {
        print("Did receive local notification with info: \(userInfo ?? [:])")
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notificationOpened)
    }

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
                self.localNotificationService.removeNotifications(
                    withIdentifiers: [contentProvider.identifier]
                )
            }
            return .value(())
        }.then {
            self.localNotificationService.scheduleNotification(contentProvider: contentProvider)
        }.catch { error in
            print("Failed schedule local notification with error: \(error)")
        }
    }

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
