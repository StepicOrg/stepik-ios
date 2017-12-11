//
//  StreaksNotificationSuggestionManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class StreaksNotificationSuggestionManager {
    fileprivate let defaults = UserDefaults.standard

    fileprivate let lastStreakAlertShownTimeKey = "lastStreakAlertShownTimeKey"
    fileprivate let streakAlertShownCntKey = "streakAlertShownCntKey"

    fileprivate let maxStreakAlertShownCnt = 3

    fileprivate var lastStreakAlertShownTime: TimeInterval {
        get {
            if let time = defaults.value(forKey: lastStreakAlertShownTimeKey) as? TimeInterval {
                return time
            } else {
                self.lastStreakAlertShownTime = 0.0
                return 0.0
            }
        }

        set(value) {
            defaults.set(value, forKey: lastStreakAlertShownTimeKey)
            defaults.synchronize()
        }
    }

    fileprivate func updateShownNotificationTime() {
        lastStreakAlertShownTime = Date().timeIntervalSince1970
    }

    fileprivate var isStreakAlertAvailableNow: Bool {
        return Date().timeIntervalSince1970 - lastStreakAlertShownTime >= 60 * 60 * 24
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

    func didShowStreakAlert() {
        streakAlertShownCnt = streakAlertShownCnt + 1
        updateShownNotificationTime()
    }

    enum StreakAlertTrigger {
        case login, submission
    }

    func canShowAlert(after trigger: StreakAlertTrigger) -> Bool {
        let commonChecks = AuthInfo.shared.isAuthorized && isStreakAlertAvailableNow && PreferencesContainer.notifications.allowStreaksNotifications == false && StepicApplicationsInfo.streaksEnabled
        switch trigger {
        case .login:
            return commonChecks && RemoteConfig.sharedConfig.ShowStreaksNotificationTrigger == .loginAndSubmission && streakAlertShownCnt == 0
        case .submission:
            return commonChecks && streakAlertShownCnt < maxStreakAlertShownCnt
        }
    }
}
