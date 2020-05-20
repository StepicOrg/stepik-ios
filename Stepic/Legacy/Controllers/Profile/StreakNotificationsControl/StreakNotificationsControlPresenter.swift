//
//  StreakNotificationsControlPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.05.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StreakNotificationsControlView: AnyObject {
    func showStreakTimeSelection(startHour: Int)
    func updateDisplayedStreakTime(startHour: Int)
    func setNotificationsSwitchIsOn(_ isOn: Bool)

    func attachPresenter(_ presenter: StreakNotificationsControlPresenter)
}

final class StreakNotificationsControlPresenter {
    weak var view: StreakNotificationsControlView?

    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let analytics: Analytics

    init(
        view: StreakNotificationsControlView,
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(
            presenter: NotificationsRequestOnlySettingsAlertPresenter(context: .streak),
            analytics: .init(source: .streakControl)
        ),
        analytics: Analytics = StepikAnalytics.shared
    ) {
        self.view = view
        self.notificationsRegistrationService = notificationsRegistrationService
        self.analytics = analytics

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

    func selectStreakNotificationTime() {
        let startHour = PreferencesContainer.notifications.streaksNotificationStartHourLocal
        view?.showStreakTimeSelection(startHour: startHour)
    }

    func refreshStreakNotificationTime() {
        let hour = PreferencesContainer.notifications.streaksNotificationStartHourUTC
        view?.updateDisplayedStreakTime(startHour: hour)
    }

    func setStreakNotifications(on allowNotifications: Bool, completion: ((Bool) -> Void)? = nil) {
        AnalyticsUserProperties.shared.setStreaksNotificationsEnabled(allowNotifications)

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
        self.analytics.send(.streaksPreferenceOn)

        completion?(true)
    }

    private func turnOffNotifications() {
        NotificationsService().cancelStreakLocalNotifications()
        PreferencesContainer.notifications.allowStreaksNotifications = false
        self.analytics.send(.streaksPreferenceOff)
    }

    private func checkPermissionStatus() {
        NotificationPermissionStatus.current.done { [weak self] status in
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
