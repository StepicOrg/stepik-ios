//
//  LocalNotificationManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class LocalNotificationManager {
    static func scheduleStreakLocalNotification(UTCStartHour: Int, cancelPrevious: Bool = true) {
        if cancelPrevious {
            cancelStreakLocalNotifications()
        }
        
        let timeZoneDiff = NSTimeZone.system.secondsFromGMT() / 3600
        var localStartHour = UTCStartHour + timeZoneDiff
        if localStartHour < 0 {
            localStartHour = 24 + localStartHour
        }
        
        if localStartHour > 23 {
            localStartHour = localStartHour - 24
        }
        
        let notification = UILocalNotification()
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        print("local start hour -> \(localStartHour) current date -> \(currentDate)")
        let date = calendar.date(bySettingHour: localStartHour, minute: 0, second: 0, of: currentDate)
        print("date set -> \(date)")
        notification.alertBody = NSLocalizedString("StreakNotificationAlertBody", comment: "")
        notification.fireDate = date
        notification.repeatInterval = NSCalendar.Unit.day
        notification.soundName = "default_sound.wav"
        
        UIApplication.shared.scheduleLocalNotification(notification)

    }
    
    static func cancelStreakLocalNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
}
