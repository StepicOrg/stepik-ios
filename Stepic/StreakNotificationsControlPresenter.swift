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
    func updateDisplayedStreakTime(startHour: Int)
    func setNotificationsSwitchIsOn(_ isOn: Bool)

    func attachPresenter(_ presenter: StreakNotificationsControlPresenter)
}

class StreakNotificationsControlPresenter {
    weak var view: StreakNotificationsControlView?
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol

    init(
        view: StreakNotificationsControlView,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(
            presenter: NotificationsRequestOnlySettingsAlertPresenter(context: .streak)
        )
    ) {
        self.view = view
        self.notificationsRegistrationService = notificationsRegistrationService

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onPermissionStatusUpdate(_:)),
            name: .notificationsRegistrationServiceDidUpdatePermissionStatus,
            object: nil
        )

        self.checkPermissionStatus()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            self.turnOffNotifications()
            completion?(false)
            return
        }

        PreferencesContainer.notifications.allowStreaksNotifications = true
        self.notificationsRegistrationService.registerForRemoteNotifications()

        guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != [] else {
            completion?(false)
            return
        }

        NotificationsService().scheduleStreakLocalNotification(
            UTCStartHour: PreferencesContainer.notifications.streaksNotificationStartHourUTC
        )
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOn, parameters: nil)

        completion?(true)
    }

    private func turnOffNotifications() {
        NotificationsService().cancelStreakLocalNotifications()
        PreferencesContainer.notifications.allowStreaksNotifications = false
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.preferencesOff, parameters: nil)
    }

    private func checkPermissionStatus() {
        NotificationPermissionStatus.current().done { [weak self] status in
            if PreferencesContainer.notifications.allowStreaksNotifications && !status.isRegistered {
                self?.turnOffNotifications()
                self?.view?.setNotificationsSwitchIsOn(false)
            }
        }
    }

    @objc
    private func onPermissionStatusUpdate(_ notification: Foundation.Notification) {
        guard let permissionStatus = notification.object as? NotificationPermissionStatus else {
            return
        }

        self.view?.setNotificationsSwitchIsOn(
            PreferencesContainer.notifications.allowStreaksNotifications && permissionStatus.isRegistered
        )
    }
}
