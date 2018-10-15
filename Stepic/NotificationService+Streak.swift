//
//  NotificationsService+Streak.swift
//  Stepic
//
//  Created by Ivan Magda on 14/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension NotificationsService {
    func scheduleStreakLocalNotification(UTCStartHour: Int, cancelPrevious: Bool = true) {
        let contentProvider = StreakLocalNotificationContentProvider(UTCStartHour: UTCStartHour)

        if cancelPrevious {
            removeLocalNotifications(withIdentifiers: [contentProvider.identifier])
        }

        scheduleLocalNotification(with: contentProvider)
    }

    func cancelStreakLocalNotifications() {
        let contentProvider = StreakLocalNotificationContentProvider(UTCStartHour: 0)
        removeLocalNotifications(withIdentifiers: [contentProvider.identifier])
    }
}
