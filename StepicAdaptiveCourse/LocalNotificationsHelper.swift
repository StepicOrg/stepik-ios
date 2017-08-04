//
//  LocalNotificationsHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

enum LocalNotification {
    var notification: UILocalNotification {
        let localNotification = UILocalNotification()
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.repeatInterval = self.repeatInterval
        localNotification.fireDate = self.fireDate
        
        switch self {
        case .tomorrow(let todayXP):
            if let todayXP = todayXP, todayXP != 0 {
                localNotification.alertBody = "Вчера Вы набрали \(todayXP) очков. Возвращайтесь и улучшите свой результат!"
            } else {
                localNotification.alertBody = "За вчерашний день Вы ничего не решили. Улучшите свой результат сегодня!"
            }
        case .weekly:
            localNotification.alertBody = "Вы давно не занимались. Возвращайтесь и продолжайте учиться!"
        }
        
        return localNotification
    }
    
    var fireDate: Date {
        switch self {
        case .tomorrow(_):
            return Date(timeIntervalSinceNow: 24 * 60 * 60)
        case .weekly:
            return Date(timeIntervalSinceNow: 2 * 24 * 60 * 60)
        }
    }
    
    var repeatInterval: NSCalendar.Unit {
        switch self {
        case .tomorrow(_):
            return NSCalendar.Unit(rawValue: 0)
        case .weekly:
            return NSCalendar.Unit.weekOfYear
        }
    }
    
    case tomorrow(todayXP: Int?)
    case weekly
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
        UIApplication.shared.registerForRemoteNotifications()
    }
}
