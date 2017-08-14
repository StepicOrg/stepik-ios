//
//  UpdatePreferencesContainer.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

/*
 Contains user preferences for version update check
 */
class UpdatePreferencesContainer: NSObject {
    fileprivate override init() {}
    static let sharedContainer = UpdatePreferencesContainer()

    fileprivate let defaults = UserDefaults.standard

    fileprivate let allowUpdateChecksKey = "allowUpdateChecks"
    fileprivate let lastUpdateCheckTimeKey = "lastUpdateCheckTime"

    var allowsUpdateChecks: Bool {
        get {
            if let allow = defaults.value(forKey: allowUpdateChecksKey) as? Bool {
                return allow
            } else {
                self.allowsUpdateChecks = true
                return true
            }
        }

        set(allowChecks) {
            defaults.set(allowChecks, forKey: allowUpdateChecksKey)
            defaults.synchronize()
        }
    }

    var lastUpdateCheckTime: TimeInterval {
        get {
            if let lastUpdate = defaults.value(forKey: lastUpdateCheckTimeKey) as? Double {
                return lastUpdate
            } else {
                self.lastUpdateCheckTime = 0.0
                return 0.0
            }
        }
        set(time) {
            defaults.set(time, forKey: lastUpdateCheckTimeKey)
            defaults.synchronize()
        }
    }
}
