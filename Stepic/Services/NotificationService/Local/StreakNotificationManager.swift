//
//  LocalNotificationManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import PromiseKit

final class StreakNotificationManager {
    static func scheduleStreakLocalNotification(UTCStartHour: Int, cancelPrevious: Bool = true) {
        let contentProvider = StreakLocalNotificationContentProvider(UTCStartHour: UTCStartHour)
        let notificationService = LocalNotificationService.shared

        if cancelPrevious {
           notificationService.removeNotifications(withIdentifiers: [contentProvider.identifier])
        }

        notificationService.scheduleNotification(contentProvider: contentProvider).catch { error in
            print(error)
        }
    }

    static func cancelStreakLocalNotifications() {
        let contentProvider = StreakLocalNotificationContentProvider(UTCStartHour: 0)
        LocalNotificationService.shared.removeNotifications(withIdentifiers: [contentProvider.identifier])
    }
}
