//
//  SubmissonManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class SubmissionManager {
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

    var canShowAlert: Bool {
        return AuthInfo.shared.isAuthorized && isStreakAlertAvailableNow && streakAlertShownCnt < maxStreakAlertShownCnt && PreferencesContainer.notifications.allowStreaksNotifications == false && StepicApplicationsInfo.streaksEnabled
    }

}
