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
    private let notificationPreferencesContainer: NotificationPreferencesContainer
    private let personalDeadlineManager: PersonalDeadlineManager

    init(
        notificationsService: NotificationsService = NotificationsService(),
        authInfo: AuthInfo = .shared,
        notificationPreferencesContainer: NotificationPreferencesContainer = NotificationPreferencesContainer(),
        personalDeadlineManager: PersonalDeadlineManager = .shared
    ) {
        self.notificationsService = notificationsService
        self.authInfo = authInfo
        self.notificationPreferencesContainer = notificationPreferencesContainer
        self.personalDeadlineManager = personalDeadlineManager
    }

    func migrateIfNeeded() {
        if self.didMigrateLocalNotifications {
            return
        }

        self.notificationsService.removeAllLocalNotifications()

        self.migrateStreakNotifications()
        self.migratePersonalDeadlinesNotifications()

        self.didMigrateLocalNotifications = true
        self.localNotificationsVersion = 2
    }

    private func migrateStreakNotifications() {
        if self.notificationPreferencesContainer.allowStreaksNotifications {
            self.notificationsService.scheduleStreakLocalNotification(
                UTCStartHour: self.notificationPreferencesContainer.streaksNotificationStartHourUTC
            )
        }
    }

    private func migratePersonalDeadlinesNotifications() {
        guard let userID = self.authInfo.userId else {
            return
        }

        for course in Course.getAllCourses(enrolled: true) {
            _ = self.personalDeadlineManager.syncDeadline(for: course, userID: userID)
        }
    }
}

extension LocalNotificationsMigrator {
    private static let didMigrateLocalNotificationsKey = "didMigrateLocalNotificationsKey"
    private static let localNotificationsVersionKey = "localNotificationsVersionKey"

    private var didMigrateLocalNotifications: Bool {
        get {
            return UserDefaults.standard.bool(forKey: LocalNotificationsMigrator.didMigrateLocalNotificationsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalNotificationsMigrator.didMigrateLocalNotificationsKey)
        }
    }

    private var localNotificationsVersion: Int {
        get {
            if let version = UserDefaults.standard.value(forKey: LocalNotificationsMigrator.localNotificationsVersionKey) as? Int {
                return version
            } else {
                return 1
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: LocalNotificationsMigrator.localNotificationsVersionKey)
        }
    }
}
