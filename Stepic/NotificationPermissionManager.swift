//
//  NotificationPermissionManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications
import PromiseKit

enum NotificationPermissionStatus {
    case notDetermined, denied, authorized

    @available(iOS 10.0, *)
    init(userNotificationAuthStatus: UNAuthorizationStatus) {
        switch userNotificationAuthStatus {
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        case .notDetermined:
            self = .notDetermined
        }
    }
}

class NotificationPermissionManager {
    func getCurrentPermissionStatus() -> Guarantee<NotificationPermissionStatus> {
        return Guarantee<NotificationPermissionStatus> { seal in
            if #available(iOS 10.0, *) {
                let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { (settings) in
                    seal(NotificationPermissionStatus(userNotificationAuthStatus: settings.authorizationStatus))
                })
            } else {
                // Fallback on earlier versions, we can not determine if we denied push notifications or not
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    seal(.authorized)
                } else {
                    seal(.notDetermined)
                }
            }

        }
    }
}
