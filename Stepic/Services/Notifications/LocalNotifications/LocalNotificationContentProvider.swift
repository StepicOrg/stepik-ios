//
//  LocalNotificationContentProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 12/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import UserNotifications

protocol LocalNotificationContentProvider {
    var title: String { get }

    var body: String { get }

    var userInfo: [AnyHashable: Any] { get }

    var identifier: String { get }

    @available(iOS, obsoleted: 10.0)
    var soundName: String { get }

    @available(iOS, obsoleted: 10.0)
    var fireDate: Date? { get }

    @available(iOS, obsoleted: 10.0)
    var repeatInterval: NSCalendar.Unit? { get }

    @available(iOS 10.0, *)
    var sound: UNNotificationSound { get }

    @available(iOS 10.0, *)
    var trigger: UNNotificationTrigger? { get }
}

extension LocalNotificationContentProvider {
    var userInfo: [AnyHashable: Any] {
        return [:]
    }

    var soundName: String {
        return UILocalNotificationDefaultSoundName
    }

    var repeatInterval: NSCalendar.Unit? {
        return nil
    }

    @available(iOS 10.0, *)
    var sound: UNNotificationSound {
        return .default
    }
}
