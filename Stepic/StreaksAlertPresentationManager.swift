//
//  StreaksAlertPresentationManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

class StreaksAlertPresentationManager {
    weak var controller: UIViewController?

    init(controller: UIViewController) {
        NotificationCenter.default.addObserver(self, selector: #selector(StreaksAlertPresentationManager.becameActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        self.controller = controller
    }

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(StreaksAlertPresentationManager.becameActive), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    @objc func becameActive() {
        if didTransitionToSettings {
            didTransitionToSettings = false
            self.notifyPressed(fromPreferences: true)
        }
    }

    private let streakTimePickerPresenter: Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .popup)
        return streakTimePickerPresenter
    }()

    private func selectStreakNotificationTime() {
        guard let controller = controller else {
            return
        }
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController
        vc.startHour = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        vc.selectedBlock = {
            [weak self] in
            if self != nil {
            }
        }
        controller.customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    private var didTransitionToSettings = false

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

    private func notifyPressed(fromPreferences: Bool) {

        guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
            if !fromPreferences {
                showStreaksSettingsNotificationAlert()
            }
            return
        }

        self.selectStreakNotificationTime()
    }

    func suggestStreak(streak: Int) {
        guard let controller = controller else {
            return
        }
        let alert = Alerts.streaks.construct(notify: {
            [weak self] in
            self?.notifyPressed(fromPreferences: false)
        })
        alert.currentStreak = streak

        Alerts.streaks.present(alert: alert, inController: controller)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
