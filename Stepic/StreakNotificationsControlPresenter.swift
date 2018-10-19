//
//  StreakNotificationsControlPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.05.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StreakNotificationsControlView: class {
    func showStreakTimeSelection(startHour: Int)
    func requestNotificationsPermissions()
    func updateDisplayedStreakTime(startHour: Int)

    func attachPresenter(_ presenter: StreakNotificationsControlPresenter)
}

class StreakNotificationsControlPresenter {
    weak var view: StreakNotificationsControlView?

    init(view: StreakNotificationsControlView) {
        self.view = view
    }

    private var notificationTimeString: String? {
        func getDisplayingStreakTimeInterval(startHour: Int) -> String {
            let startInterval = TimeInterval((startHour % 24) * 60 * 60)
            let startDate = Date(timeIntervalSinceReferenceDate: startInterval)
            let endInterval = TimeInterval((startHour + 1) % 24 * 60 * 60)
            let endDate = Date(timeIntervalSinceReferenceDate: endInterval)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
        }

        let hasPermissionToSendStreakNotifications = PreferencesContainer.notifications.allowStreaksNotifications
        let streaksNotificationStartHour = PreferencesContainer.notifications.streaksNotificationStartHourUTC
        if hasPermissionToSendStreakNotifications {
            return getDisplayingStreakTimeInterval(startHour: streaksNotificationStartHour)
        } else {
            return nil
        }
    }

    func selectStreakNotificationTime() {
        let startHour = PreferencesContainer.notifications.streaksNotificationStartHourLocal
        view?.showStreakTimeSelection(startHour: startHour)
    }

    func refreshStreakNotificationTime() {
        let hour = PreferencesContainer.notifications.streaksNotificationStartHourUTC
        view?.updateDisplayedStreakTime(startHour: hour)
    }

    func setStreakNotifications(on allowNotifications: Bool, completion: ((Bool) -> Void)? = nil) {
        if !allowNotifications {
            NotificationsService().cancelStreakLocalNotifications()
            PreferencesContainer.notifications.allowStreaksNotifications = false
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOff, parameters: nil)
            completion?(false)
            return
        }

        guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
            view?.requestNotificationsPermissions()
            completion?(false)
            return
        }

        PreferencesContainer.notifications.allowStreaksNotifications = true
        NotificationsRegistrationService().register(forceToRequestAuthorization: true)
        NotificationsService().scheduleStreakLocalNotification(UTCStartHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC)
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOn, parameters: nil)
        completion?(true)
    }
}
