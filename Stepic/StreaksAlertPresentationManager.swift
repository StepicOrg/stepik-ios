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

protocol StreaksAlertPresentationDelegate: class {
    func didDismiss()
}

class StreaksAlertPresentationManager {
    weak var controller: UIViewController?
    weak var delegate: StreaksAlertPresentationDelegate?

    var source: StreaksAlertPresentationSource?
    private var didTransitionToSettings = false
    var notificationPermissionManager: NotificationPermissionManager

    enum StreaksAlertPresentationSource: String {
        case login = "login"
        case submission = "submission"
    }

    init(source: StreaksAlertPresentationSource, notificationPermissionManager: NotificationPermissionManager = NotificationPermissionManager()) {
        self.source = source
        self.notificationPermissionManager = notificationPermissionManager
        NotificationCenter.default.addObserver(self, selector: #selector(StreaksAlertPresentationManager.becameActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    @objc func becameActive() {
        if didTransitionToSettings {
            didTransitionToSettings = false
            cameFromSettings()
        }
    }

    private let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .popup)
        return streakTimePickerPresenter
    }()

    private func didChooseTime() {
        if let controller = controller as? ProfileViewController {
            controller.onAppear()
        }
    }

    private func selectStreakNotificationTime() {
        guard let controller = controller else {
            return
        }
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = PreferencesContainer.notifications.streaksNotificationStartHourLocal
        vc.selectedBlock = {
            [weak self] in
            if let source = self?.source?.rawValue {
                AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notifySuggestionApproved(source: source, trigger: RemoteConfig.shared.showStreaksNotificationTrigger.rawValue))
            }
            self?.didChooseTime()
            self?.delegate?.didDismiss()
        }
        vc.cancelAction = {
            [weak self] in
            self?.delegate?.didDismiss()
        }
        controller.customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    private func showStreaksSettingsNotificationAlert() {
        guard let controller = controller else {
            return
        }
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            [weak self]
            _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            self?.didTransitionToSettings = true
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))

        controller.present(alert, animated: true, completion: nil)
    }

    func notifyPressed() {
        notificationPermissionManager.getCurrentPermissionStatus().done { [weak self] status in
            switch status {
            case .notDetermined:
                NotificationRegistrator.shared.registerForRemoteNotifications()
                self?.selectStreakNotificationTime()
            case .authorized:
                self?.selectStreakNotificationTime()
            case .denied:
                self?.showStreaksSettingsNotificationAlert()
            }
            return
        }
    }

    func cameFromSettings() {
        notificationPermissionManager.getCurrentPermissionStatus().done { [weak self] status in
            switch status {
            case .notDetermined:
                // Actually, it should never come here, but just in case
                NotificationRegistrator.shared.registerForRemoteNotifications()
            case .authorized:
                self?.selectStreakNotificationTime()
            case .denied:
                //TODO: Add dialog to tell user he should have permitteed the notifications
                self?.delegate?.didDismiss()
            }
            return
        }

    }

    func suggestStreak(streak: Int) {
        guard let controller = controller else {
            return
        }
        let alert = Alerts.streaks.construct(presentationManager: self)

        alert.currentStreak = streak

        if let source = source?.rawValue {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notifySuggestionShown(source: source, trigger: RemoteConfig.shared.showStreaksNotificationTrigger.rawValue))
        }
        Alerts.streaks.present(alert: alert, inController: controller)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
