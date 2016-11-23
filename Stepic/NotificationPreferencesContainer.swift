//
//  NotificationPreferencesContainer.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class NotificationPreferencesContainer {
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate let allowStreaksNotificationKey = "allowStreaksNotification"
    fileprivate let streaksNotificationStartHourKey = "streaksNotificationStartHourKey"

    
    var allowStreaksNotifications: Bool {
        get {
            if let allow = defaults.value(forKey: allowStreaksNotificationKey) as? Bool {
                return allow
            } else {
                self.allowStreaksNotifications = false
                return true
            }
        }
        
        set(allowStreaksNotification) {
            defaults.set(allowStreaksNotification, forKey: allowStreaksNotificationKey)
            defaults.synchronize()
        }
    }
    
    
    var streaksNotificationStartHour: Int {
        get {
            return (defaults.value(forKey: streaksNotificationStartHourKey) as? Int) ?? 12
        } 
        set(start) {
            defaults.set(start, forKey: streaksNotificationStartHourKey)
            defaults.synchronize()
        }
    }
}
