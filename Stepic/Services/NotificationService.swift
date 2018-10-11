//
//  NotificationService.swift
//  Stepic
//
//  Created by Ivan Magda on 11/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

final class NotificationService: NSObject {

    static let shared = NotificationService()

    private override init() {
        super.init()

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }

    // MARK: Public API

    func handleApplicationLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions else {
            return
        }

        if launchOptions[.localNotification] != nil {
            handleLocalNotification()
        } else if let remoteNotification = launchOptions[.remoteNotification] as? [String: Any] {
            handleRemoteNotification(remoteNotification)
        }
    }

    func handleLocalNotification() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notificationOpened)
    }

    func handleRemoteNotification(_ notification: [String: Any]) {
//        guard let reaction = NotificationReactionHandler.handle(with: notification),
//              let topController = self.currentNavigationController?.topViewController else {
//            return
//        }
//        reaction(topController)
        print(notification)
    }
}

@available(iOS 10.0, *)
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // We are handle a notification that arrived while the app was running in the foreground
        // and presents it with alert and sound.
        // Next `application(_:didReceive:)` will be called.
        completionHandler([.alert, .sound])
    }
}
