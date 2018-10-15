//
//  LocalNotificationsMigrator.swift
//  Stepic
//
//  Created by Ivan Magda on 15/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LocalNotificationsMigrator {
    private let notificationsService: NotificationsService
    private let authInfo: AuthInfo

    init(notificationsService: NotificationsService = .shared, authInfo: AuthInfo = .shared) {
        self.notificationsService = notificationsService
        self.authInfo = authInfo
    }

    func migrateIfNeeded() {
        guard !DefaultsContainer.notifications.didMigrateLocalNotifications else {
            return
        }

        notificationsService.removeAllLocalNotifications()

        migrateStreakNotifications()
        migratePersonalDeadlinesNotifications()

        DefaultsContainer.notifications.didMigrateLocalNotifications = true
        DefaultsContainer.notifications.localNotificationsVersion = 2
    }

    private func migrateStreakNotifications() {
        guard PreferencesContainer.notifications.allowStreaksNotifications else {
            return
        }

        notificationsService.scheduleStreakLocalNotification(
            UTCStartHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC
        )
    }

    private func migratePersonalDeadlinesNotifications() {
        guard let userID = authInfo.userId else {
            return
        }

        for course in Course.getAllCourses(enrolled: true) {
            _ = PersonalDeadlineManager.shared.syncDeadline(
                for: course,
                userID: userID
            )
        }
    }
}
