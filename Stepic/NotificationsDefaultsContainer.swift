//
//  NotificationsDefaultsContainer.swift
//  Stepic
//
//  Created by Ivan Magda on 15/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class NotificationsDefaultsContainer {
    private let defaults = UserDefaults.standard

    private let didMigrateLocalNotificationsKey = "didMigrateLocalNotificationsKey"
    private let localNotificationsVersionKey = "localNotificationsVersionKey"

    var didMigrateLocalNotifications: Bool {
        get {
            if let did = defaults.value(forKey: didMigrateLocalNotificationsKey) as? Bool {
                return did
            } else {
                return false
            }
        }
        set {
            defaults.set(newValue, forKey: didMigrateLocalNotificationsKey)
            defaults.synchronize()
        }
    }

    var localNotificationsVersion: Int {
        get {
            if let version = defaults.value(forKey: localNotificationsVersionKey) as? Int {
                return version
            } else {
                return 1
            }
        }
        set {
            defaults.set(newValue, forKey: localNotificationsVersionKey)
            defaults.synchronize()
        }
    }
}
