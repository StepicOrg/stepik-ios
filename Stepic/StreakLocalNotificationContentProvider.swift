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
        NSString.localizedUserNotificationString(forKey: "StreakNotificationAlertBody", arguments: nil)
    }

    var userInfo: [AnyHashable: Any] {
        [NotificationsService.PayloadKey.type.rawValue: NotificationsService.NotificationType.streak.rawValue]
    }

    var identifier: String { "\(NotificationsService.NotificationType.streak.rawValue)_local_notification" }

    var soundName: String { "default_sound.wav" }

    var sound: UNNotificationSound { UNNotificationSound(named: UNNotificationSoundName(self.soundName)) }

    var trigger: UNNotificationTrigger? {
        UNCalendarNotificationTrigger(dateMatching: self.dateComponents, repeats: true)
    }

    init(UTCStartHour: Int, calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.UTCStartHour = UTCStartHour
        self.calendar = calendar
    }
}
