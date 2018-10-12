//
//  StreakLocalNotificationContentProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 12/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

final class StreakLocalNotificationContentProvider: LocalNotificationContentProvider {
    var title: String = ""

    var body: String {
        if #available(iOS 10.0, *) {
            return NSString.localizedUserNotificationString(forKey: "StreakNotificationAlertBody", arguments: nil)
        } else {
            return NSLocalizedString("StreakNotificationAlertBody", comment: "")
        }
    }

    var identifier: String = "streak_local_notification"

    var userInfo: [AnyHashable : Any]?

    var soundName: String = "default_sound.wav"

    @available(iOS 10.0, *)
    var sound: UNNotificationSound {
        return UNNotificationSound(named: soundName)
    }

    var repeatInterval: NSCalendar.Unit? = NSCalendar.Unit.day

    var fireDate: Date? {
        return calendar.date(from: dateComponents)
    }

    @available(iOS 10.0, *)
    var trigger: UNNotificationTrigger? {
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    }

    let UTCStartHour: Int

    private let calendar = Calendar(identifier: .gregorian)

    private var dateComponents: DateComponents {
        let timeZoneDiff = NSTimeZone.system.secondsFromGMT() / 3600
        var localStartHour = UTCStartHour + timeZoneDiff

        if localStartHour < 0 {
            localStartHour = 24 + localStartHour
        }
        if localStartHour > 23 {
            localStartHour = localStartHour - 24
        }

        let currentDate = Date()

        var components = DateComponents()
        components.year = calendar.component(.year, from: currentDate)
        components.month = calendar.component(.month, from: currentDate)
        components.day = calendar.component(.day, from: currentDate)
        components.hour = localStartHour
        components.minute = 0
        components.second = 0

        return components
    }

    init(UTCStartHour: Int) {
        self.UTCStartHour = UTCStartHour
    }
}
