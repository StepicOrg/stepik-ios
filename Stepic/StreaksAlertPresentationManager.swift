//
//  StreaksAlertPresentationManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr
import PromiseKit

final class StreaksAlertPresentationManager {
    weak var controller: UIViewController?
    var source: Source?

    private var alertPresenter: NotificationsRegistrationServicePresenterProtocol?
    private var didTransitionToSettings = false

    private let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .popup)
        return streakTimePickerPresenter
    }()

    init(source: Source) {
        self.source = source

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(StreaksAlertPresentationManager.becameActive),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func suggestStreak(streak: Int) {
        guard let controller = self.controller else {
            return
        }

        if let source = source?.rawValue {
            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Streaks.notifySuggestionShown(
                    source: source,
                    trigger: RemoteConfig.shared.showStreaksNotificationTrigger.rawValue
                )
            )
        }

        let presenter = NotificationsRequestAlertPresenter(
            context: .streak,
            presentationType: .dynamic(center: .center),
            dataSource: StreakNotificationsRequestAlertDataSource(streak: streak),
            presentAlertIfRegistered: true
        )
        presenter.onPositiveCallback = { [weak self] in
            PreferencesContainer.notifications.allowStreaksNotifications = true

            let notificationSuggestionManager = NotificationSuggestionManager()
            notificationSuggestionManager.didShowAlert(context: .streak)

            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Streaks.Suggestion.success(
                    notificationSuggestionManager.streakAlertShownCnt
                )
            )

            self?.notifyPressed()
        }
        presenter.onCancelCallback = {
            PreferencesContainer.notifications.allowStreaksNotifications = false

            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Streaks.Suggestion.fail(
                    NotificationSuggestionManager().streakAlertShownCnt
                )
            )
        }

        self.alertPresenter = presenter
        self.alertPresenter?.presentAlert(for: .permission, inController: controller)
    }

    @objc
    private func becameActive() {
        if self.didTransitionToSettings {
            self.didTransitionToSettings = false
            self.cameFromSettings()
        }
    }

    private func didChooseTime() {
        if let controller = controller as? ProfileViewController {
            controller.onAppear()
        }
    }

    private func selectStreakNotificationTime() {
        guard let controller = controller else {
            return
        }

        let vc = NotificationTimePickerViewController(
            nibName: "PickerViewController",
            bundle: nil
        ) as NotificationTimePickerViewController

        vc.startHour = PreferencesContainer.notifications.streaksNotificationStartHourLocal
        vc.selectedBlock = { [weak self] in
            if let source = self?.source?.rawValue {
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Streaks.notifySuggestionApproved(
                        source: source,
                        trigger: RemoteConfig.shared.showStreaksNotificationTrigger.rawValue
                    )
                )
            }

            self?.didChooseTime()
        }
        vc.cancelAction = {
        }

        controller.customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true)
    }

    private func notifyPressed() {
        NotificationPermissionStatus.current.done { [weak self] status in
            switch status {
            case .notDetermined:
                NotificationsRegistrationService().registerForRemoteNotifications()
                self?.selectStreakNotificationTime()
            case .authorized:
                self?.selectStreakNotificationTime()
            case .denied:
                self?.showSettingsAlert()
            }
            return
        }
    }

    private func showSettingsAlert() {
        guard let controller = self.controller,
              var alertPresenter = self.alertPresenter else {
            return
        }

        alertPresenter.onPositiveCallback = { [weak self] in
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                self?.didTransitionToSettings = true
                UIApplication.shared.openURL(settingsURL)
            }
        }

        alertPresenter.presentAlert(for: .settings, inController: controller)
    }

    private func cameFromSettings() {
        NotificationPermissionStatus.current.done { [weak self] status in
            switch status {
            case .notDetermined:
                NotificationsRegistrationService().registerForRemoteNotifications()
            case .authorized:
                self?.selectStreakNotificationTime()
            case .denied:
                break
            }
        }
    }

    enum Source: String {
        case login = "login"
        case submission = "submission"
    }
}
