//
//  UserNotificationsCenterDelegate.swift
//  Stepic
//
//  Created by Ivan Magda on 16/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

final class UserNotificationsCenterDelegate: NSObject {
    func attachNotificationDelegate() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
}

@available(iOS 10.0, *)
extension UserNotificationsCenterDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound])
    }
}
