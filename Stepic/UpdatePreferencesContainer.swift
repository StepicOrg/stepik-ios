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
    private override init() {}
    static let sharedContainer = UpdatePreferencesContainer()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private let allowUpdateChecksKey = "allowUpdateChecks"
    private let lastUpdateCheckTimeKey = "lastUpdateCheckTime"
    
    var allowsUpdateChecks: Bool {
        get {
            if let allow = defaults.valueForKey(allowUpdateChecksKey) as? Bool {
                return allow
            } else {
                self.allowsUpdateChecks = true
                return true
            }
        }
        
        set(allowChecks) {
            defaults.setObject(allowChecks, forKey: allowUpdateChecksKey)
            defaults.synchronize()
        }
    }
    
    var lastUpdateCheckTime: NSTimeInterval {
        get {
            if let lastUpdate = defaults.valueForKey(lastUpdateCheckTimeKey) as? Double {
                return lastUpdate
            } else {
                self.lastUpdateCheckTime = 0.0
                return 0.0
            }
        } 
        set(time) {
            defaults.setObject(time, forKey: lastUpdateCheckTimeKey)
            defaults.synchronize()
        }
    }
}
