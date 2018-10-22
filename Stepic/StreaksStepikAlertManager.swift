//
//  StreaksStepikAlertManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

/*
 AlertManager class for streaks alert
 */
class StreaksStepikAlertManager: AlertManager, StreaksAlertPresentationDelegate {
    func present(alert: UIViewController, inController controller: UIViewController) {
        controller.customPresentViewController(presenter, viewController: alert, animated: true)
    }

    //TODO: Add DI here
    var presentationManager: StreaksAlertPresentationManager?
    var streaksNotificationSuggestionManager = NotificationSuggestionManager()

    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .dynamic(center: .center))
        presenter.roundCorners = true
        return presenter
    }()

    func construct(presentationManager: StreaksAlertPresentationManager) -> NotificationRequestAlertViewController {
        self.presentationManager = presentationManager
        presentationManager.delegate = self
        let alert = NotificationRequestAlertViewController(nibName: "NotificationRequestAlertViewController", bundle: nil)
        alert.context = .streak
        alert.yesAction = {
            [weak self] in
            PreferencesContainer.notifications.allowStreaksNotifications = true

            guard let strongSelf = self else {
                return
            }
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.Suggestion.success(strongSelf.streaksNotificationSuggestionManager.streakAlertShownCnt))
            strongSelf.presentationManager?.notifyPressed()
        }
        alert.noAction = {
            [weak self] in
            PreferencesContainer.notifications.allowStreaksNotifications = false

            guard let strongSelf = self else {
                return
            }
            AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.Suggestion.fail(strongSelf.streaksNotificationSuggestionManager.streakAlertShownCnt))
            strongSelf.presentationManager = nil
        }
        return alert
    }

    func didDismiss() {
        self.presentationManager = nil
    }
}
