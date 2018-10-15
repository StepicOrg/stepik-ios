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

    var userInfo: [AnyHashable: Any]? { get }

    var identifier: String { get }

    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework's `UNNotificationSound.default()`")
    var soundName: String { get }

    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework's `UNNotificationTrigger`")
    var fireDate: Date? { get }

    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework's `UNNotificationTrigger`")
    var repeatInterval: NSCalendar.Unit? { get }

    @available(iOS 10.0, *)
    var sound: UNNotificationSound { get }

    @available(iOS 10.0, *)
    var trigger: UNNotificationTrigger? { get }
}
