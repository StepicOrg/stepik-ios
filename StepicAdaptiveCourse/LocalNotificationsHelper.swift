//
//  LocalNotificationsHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

enum LocalNotification {
    case tomorrow, weekly

    var fireDate: Date {
        switch self {
        case .tomorrow:
            return Date(timeIntervalSinceNow: 24 * 60 * 60)
        case .weekly:
            return Date(timeIntervalSinceNow: 2 * 24 * 60 * 60)
        }
    }

    var repeatInterval: NSCalendar.Unit {
        switch self {
        case .tomorrow:
            return NSCalendar.Unit(rawValue: 0)
        case .weekly:
            return NSCalendar.Unit.weekOfYear
        }
    }

    var notification: UILocalNotification {
        let localNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.repeatInterval = self.repeatInterval
        localNotification.fireDate = self.fireDate

        switch self {
        case .tomorrow:
            let streak = StatsManager.shared.currentDayStreak
            if streak == 0 {
                // 0 points today, 0 points prev
                localNotification.alertBody = NSLocalizedString("RetentionNotificationYesterdayZero", comment: "")
                localNotification.userInfo = ["type": "yesterday_zero"]
            } else if streak == 1 {
                // X points today, 0 points prev
                if let todayXP = StatsManager.shared.getLastDays(count: 1).first {
                    localNotification.alertBody = String(format: NSLocalizedString("RetentionNotificationYesterday", comment: ""), "\(todayXP)")
                    localNotification.userInfo = ["type": "yesterday"]
                }
            } else {
                // X points today, X points prev
                var streakDays = "\(streak) "
                switch (streak % 10) {
                case 1: streakDays += NSLocalizedString("days1", comment: "")
                case 2, 3, 4: streakDays += NSLocalizedString("days234", comment: "")
                default: streakDays += NSLocalizedString("days567890", comment: "")
                }

                localNotification.alertBody = String(format: NSLocalizedString("RetentionNotificationYesterdayStreak", comment: ""), "\(streakDays)")
                localNotification.userInfo = ["type": "yesterday_streak"]
            }
        case .weekly:
            localNotification.alertBody = NSLocalizedString("RetentionNotificationWeekly", comment: "")
            localNotification.userInfo = ["type": "weekly"]
        }

        return localNotification
    }
}

class LocalNotificationsHelper {
    static func cancelAllNotifications() {
        print("local notifications: cancelled all")
        UIApplication.shared.cancelAllLocalNotifications()
    }

    static func schedule(notification: LocalNotification) {
        print("local notifications: scheduled notification with fire date = \(notification.fireDate)")
        UIApplication.shared.scheduleLocalNotification(notification.notification)
    }

    static func registerNotifications() {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
}
