//
//  NotificationPreferencesContainer.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Legacy class")
final class NotificationPreferencesContainer {
    private let defaults = UserDefaults.standard

    private let allowStreaksNotificationKey = "allowStreaksNotification"
    private let streaksNotificationStartHourUTCKey = "streaksNotificationStartHourUTCKey"

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

    private var defaultUTCStartHour: Int {
        (24 + 20 - (NSTimeZone.system.secondsFromGMT() / 60 / 60)) % 24
    }

    var streaksNotificationStartHourUTC: Int {
        get {
            (defaults.value(forKey: streaksNotificationStartHourUTCKey) as? Int) ?? defaultUTCStartHour
        }
        set(start) {
            defaults.set(start, forKey: streaksNotificationStartHourUTCKey)
            defaults.synchronize()
        }
    }

    var streaksNotificationStartHourLocal: Int {
        let time = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        return time < 0 ? 24 + time : time
    }
}
