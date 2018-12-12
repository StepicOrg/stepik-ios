//
//  StreakLocalNotificationContentProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 15/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

final class StreakLocalNotificationContentProvider: LocalNotificationContentProvider {
    private let UTCStartHour: Int
    private let calendar: Calendar

    private var dateComponents: DateComponents {
        let timeZoneDiff = NSTimeZone.system.secondsFromGMT() / 3600
        var localStartHour = self.UTCStartHour + timeZoneDiff

        if localStartHour < 0 {
            localStartHour = 24 + localStartHour
        }
        if localStartHour > 23 {
            localStartHour = localStartHour - 24
        }

        return DateComponents(hour: localStartHour)
    }

    var title = ""

    var body: String {
        if #available(iOS 10.0, *) {
            return NSString.localizedUserNotificationString(forKey: "StreakNotificationAlertBody", arguments: nil)
        } else {
            return NSLocalizedString("StreakNotificationAlertBody", comment: "")
        }
    }

    var userInfo: [AnyHashable: Any] {
        return [
            NotificationsService.PayloadKey.type.rawValue: NotificationsService.NotificationType.streak.rawValue
        ]
    }

    var identifier: String {
        return "\(NotificationsService.NotificationType.streak.rawValue)_local_notification"
    }

    var soundName: String {
        return "default_sound.wav"
    }

    var repeatInterval: NSCalendar.Unit? {
        return .day
    }

    var fireDate: Date? {
        return self.calendar.date(from: self.dateComponents)
    }

    @available(iOS 10.0, *)
    var sound: UNNotificationSound {
        return UNNotificationSound(named: self.soundName)
    }

    @available(iOS 10.0, *)
    var trigger: UNNotificationTrigger? {
        return UNCalendarNotificationTrigger(dateMatching: self.dateComponents, repeats: true)
    }

    init(UTCStartHour: Int, calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.UTCStartHour = UTCStartHour
        self.calendar = calendar
    }
}
