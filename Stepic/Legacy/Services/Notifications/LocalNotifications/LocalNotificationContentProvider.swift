//
//  LocalNotificationContentProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 12/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

protocol LocalNotificationContentProvider {
    var title: String { get }

    var body: String { get }

    var userInfo: [AnyHashable: Any] { get }

    var identifier: String { get }

    var sound: UNNotificationSound { get }

    var trigger: UNNotificationTrigger? { get }
}

extension LocalNotificationContentProvider {
    var userInfo: [AnyHashable: Any] { [:] }

    var sound: UNNotificationSound { .default }
}
