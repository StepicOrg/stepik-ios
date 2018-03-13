//
//  Alerts.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Class, which contains different alert managers
 */
class Alerts {
    static let streaks = StreaksStepikAlertManager()
    static let rate = RateAppAlertManager()
    static let notificationRequest = NotificationRequestAlertManager()
}
