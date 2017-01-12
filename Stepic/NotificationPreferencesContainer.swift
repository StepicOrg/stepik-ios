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
    fileprivate let streaksNotificationStartHourUTCKey = "streaksNotificationStartHourUTCKey"

    
    var allowStreaksNotifications: Bool {
        get {
            if let allow = defaults.value(forKey: allowStreaksNotificationKey) as? Bool {
                return allow
            } else {
                self.allowStreaksNotifications = false
                return false
            }
        }
        
        set(value) {
            defaults.set(value, forKey: allowStreaksNotificationKey)
            defaults.synchronize()
        }
    }
    
    fileprivate var defaultUTCStartHour : Int {
        return (24 + 20 - (NSTimeZone.system.secondsFromGMT() / 60 / 60)) % 24
    }
    
    
    var streaksNotificationStartHourUTC: Int {
        get {
            return (defaults.value(forKey: streaksNotificationStartHourUTCKey) as? Int) ?? defaultUTCStartHour
        } 
        set(start) {
            defaults.set(start, forKey: streaksNotificationStartHourUTCKey)
            defaults.synchronize()
        }
    }
}
