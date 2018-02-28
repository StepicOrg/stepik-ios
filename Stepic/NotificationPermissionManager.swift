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
    func getCurrentPermissionStatus() -> Promise<NotificationPermissionStatus> {
        return Promise {
            fulfill, reject in
            if #available(iOS 10.0, *) {
                let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { (settings) in
                    fulfill(NotificationPermissionStatus(userNotificationAuthStatus: settings.authorizationStatus))
                })
            } else {
                // Fallback on earlier versions
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    fulfill(.authorized)
                } else {
                    fulfill(didAskForPermission ? .denied : .notDetermined)
                }
            }

        }
    }
    
    private let didAskForRemoteNotificationPermissionKey = "didAskForRemoteNotificationPermissionKey"
    
    var didAskForPermission: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: didAskForRemoteNotificationPermissionKey)
        }
        get {
            return UserDefaults.standard.value(forKey: didAskForRemoteNotificationPermissionKey) as? Bool ?? false
        }
    }
}
