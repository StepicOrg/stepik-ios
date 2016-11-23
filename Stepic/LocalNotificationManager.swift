//
//  LocalNotificationManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class LocalNotificationManager {
    static func scheduleStreakLocalNotification(startHour: Int, cancelPrevious: Bool = true) {
        if cancelPrevious {
            cancelStreakLocalNotifications()
        }
        
        let notification = UILocalNotification()
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: Date())
        
        notification.alertBody = "Would like some courses, huh?"
        notification.fireDate = date
        notification.repeatInterval = NSCalendar.Unit.day
        notification.soundName = "default_sound.wav"
        
        UIApplication.shared.scheduleLocalNotification(notification)
        
    }
    
    static func cancelStreakLocalNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
}
