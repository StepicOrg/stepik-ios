//
//  RateAppManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class RateAppManager {
    private let defaults = UserDefaults.standard

    private let correctSubmissionsThreshold = StepikApplicationsInfo.RateApp.correctSubmissionsThreshold

    private let showRateLaterPressedDateKey = "showRateLaterPressedDateKey"

    private let correctSubmissionsCountKey = "correctSubmissionsCountKey"

    private let neverShowRateAlertKey = "neverShowRateAlertKey"

    private var showRateLaterPressedDate: TimeInterval? {
        get {
            defaults.value(forKey: showRateLaterPressedDateKey) as? TimeInterval
        }
        set(value) {
            defaults.set(value, forKey: showRateLaterPressedDateKey)
            defaults.synchronize()
        }
    }

    private var neverShowRateAlert: Bool {
        get {
            defaults.value(forKey: neverShowRateAlertKey) as? Bool ?? false
        }
        set(value) {
            defaults.set(value, forKey: neverShowRateAlertKey)
            defaults.synchronize()
        }
    }

    private var correctSubmissionsCount: Int {
        get {
            if let cnt = defaults.value(forKey: correctSubmissionsCountKey) as? Int {
                return cnt
            } else {
                self.correctSubmissionsCount = 0
                return 0
            }
        }
        set(value) {
            defaults.set(value, forKey: correctSubmissionsCountKey)
            defaults.synchronize()
        }
    }

    //returns true if rate alert should be shown
    func submittedCorrect() -> Bool {
        if canShowAfterLaterPressed && !neverShowRateAlert {
            correctSubmissionsCount += 1
            if correctSubmissionsCount >= correctSubmissionsThreshold {
                return true
            }
        }
        return false
    }

    func pressedShowLater() {
        showRateLaterPressedDate = NSDate().timeIntervalSince1970
        correctSubmissionsCount = 0
    }

    func neverShow() {
        neverShowRateAlert = true
    }

    var canShowAfterLaterPressed: Bool {
        guard let lastPressedInterval = showRateLaterPressedDate else {
            return true
        }

        return NSDate().timeIntervalSince1970 > lastPressedInterval.advanced(by: 60 * 60 * 24)
    }
}
