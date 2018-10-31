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
    private let source: Source

    private var alertPresenter: NotificationsRegistrationServicePresenterProtocol?
    private var didTransitionToSettings = false

    private lazy var notificationsRegistrationService: NotificationsRegistrationServiceProtocol = {
        NotificationsRegistrationService(analytics: .init(source: self.source.analyticsSource))
    }()

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

        AnalyticsReporter.reportEvent(
            AnalyticsEvents.Streaks.notifySuggestionShown(
                source: self.source.rawValue,
                trigger: RemoteConfig.shared.showStreaksNotificationTrigger.rawValue
            )
        )

        let presenter = NotificationsRequestAlertPresenter(
            context: .streak,
            dataSource: StreakNotificationsRequestAlertDataSource(streak: streak),
            presentAlertIfRegistered: true
        )
        let source = self.source.analyticsSource
        presenter.onPositiveCallback = { [weak self] in
            PreferencesContainer.notifications.allowStreaksNotifications = true

            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Streaks.Suggestion.success(
                    NotificationSuggestionManager().streakAlertShownCnt
                )
            )
            NotificationAlertsAnalytics(source: source).reportCustomAlertInteractionResult(.yes)

            // When we are suggesting streak with the `Source` of .login type - `self` will be deallocated at this point.
            // In this case we need to register for remote notifications.
            if let strongSelf = self {
                strongSelf.notifyPressed()
            } else {
                NotificationsRegistrationService(
                    analytics: .init(source: source)
                ).registerForRemoteNotifications()
            }
        }
        presenter.onCancelCallback = {
            PreferencesContainer.notifications.allowStreaksNotifications = false

            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Streaks.Suggestion.fail(
                    NotificationSuggestionManager().streakAlertShownCnt
                )
            )
            NotificationAlertsAnalytics(source: source).reportCustomAlertInteractionResult(.no)
        }

        self.alertPresenter = presenter
        self.alertPresenter?.presentAlert(for: .permission, inController: controller)

        NotificationSuggestionManager().didShowAlert(context: .streak)
        NotificationAlertsAnalytics(source: source).reportCustomAlertShown()
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
            guard let strongSelf = self else {
                return
            }

            AnalyticsReporter.reportEvent(
                AnalyticsEvents.Streaks.notifySuggestionApproved(
                    source: strongSelf.source.rawValue,
                    trigger: RemoteConfig.shared.showStreaksNotificationTrigger.rawValue
                )
            )

            strongSelf.didChooseTime()
        }
        vc.cancelAction = {
        }

        controller.customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true)
    }

    private func notifyPressed() {
        NotificationPermissionStatus.current.done { [weak self] status in
            switch status {
            case .notDetermined:
                self?.notificationsRegistrationService.registerForRemoteNotifications()
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
                self?.notificationsRegistrationService.registerForRemoteNotifications()
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

        var analyticsSource: NotificationAlertsAnalytics.Source {
            switch self {
            case .login:
                return .streakAfterLogin
            case .submission:
                return .streakAfterSubmission(
                    shownCount: NotificationSuggestionManager().streakAlertShownCnt
                )
            }
        }
    }
}
