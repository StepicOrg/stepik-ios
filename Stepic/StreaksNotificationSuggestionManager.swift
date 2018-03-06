//
//  NotificationSuggestionManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class NotificationSuggestionManager {
    private let defaults = UserDefaults.standard

    private let streakAlertShownCntKey = "streakAlertShownCntKey"

    private let lastStreakAlertShownTimeKey = "lastStreakAlertShownTimeKey"
    private let lastNotificationsTabNotificationRequestShownTimeKey = "lastNotificationsTabNotificationRequestShownTimeKey"
    private let lastCourseSubscriptionNotificationRequestShownTimeKey = "lastCourseSubscriptionNotificationRequestShownTimeKey"

    func lastTimeKey(for context: NotificationRequestAlertContext) -> String {
        switch context {
        case .streak:
            return lastStreakAlertShownTimeKey
        case .courseSubscription:
            return lastCourseSubscriptionNotificationRequestShownTimeKey
        case .notificationsTab:
            return lastNotificationsTabNotificationRequestShownTimeKey
        }
    }

    private let maxStreakAlertShownCnt = 3

    private func getLastAlertShownTime(for context: NotificationRequestAlertContext) -> TimeInterval {
        if let time = defaults.value(forKey: lastTimeKey(for: context)) as? TimeInterval {
            return time
        } else {
            setLastAlertShownTime(time: 0.0, for: context)
            return 0.0
        }
    }

    private func setLastAlertShownTime(time: TimeInterval, for context: NotificationRequestAlertContext) {
        defaults.set(time, forKey: lastTimeKey(for: context))
        defaults.synchronize()
    }

    private func updateShownNotificationTime(for context: NotificationRequestAlertContext) {
        setLastAlertShownTime(time: Date().timeIntervalSince1970, for: context)
    }

    private func isAlertAvailableNow(context: NotificationRequestAlertContext) -> Bool {
        return Date().timeIntervalSince1970 - getLastAlertShownTime(for: context) >= 60 * 60 * 24
    }

    var streakAlertShownCnt: Int {
        get {
            if let cnt = defaults.value(forKey: streakAlertShownCntKey) as? Int {
                return cnt
            } else {
                self.streakAlertShownCnt = 0
                return 0
            }
        }

        set(value) {
            defaults.set(value, forKey: streakAlertShownCntKey)
            defaults.synchronize()
        }
    }

    func didShowAlert(context: NotificationRequestAlertContext) {
        switch context {
        case .streak:
            streakAlertShownCnt = streakAlertShownCnt + 1
        default:
            break
        }
        updateShownNotificationTime(for: context)
    }

    enum StreakAlertTrigger {
        case login, submission
    }

    func canShowAlert(context: NotificationRequestAlertContext, after trigger: StreakAlertTrigger? = nil) -> Bool {
        switch context {
        case .streak:
            guard let trigger = trigger else {
                return false
            }
            let commonChecks = AuthInfo.shared.isAuthorized && isAlertAvailableNow(context: context) && PreferencesContainer.notifications.allowStreaksNotifications == false && StepicApplicationsInfo.streaksEnabled
            switch trigger {
            case .login:
                return commonChecks && RemoteConfig.shared.showStreaksNotificationTrigger == .loginAndSubmission && streakAlertShownCnt == 0
            case .submission:
                return commonChecks && streakAlertShownCnt < maxStreakAlertShownCnt
            }
        case .notificationsTab, .courseSubscription:
            return isAlertAvailableNow(context: context) && AuthInfo.shared.isAuthorized
        }
    }
}
