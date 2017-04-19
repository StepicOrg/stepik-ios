//
//  RateAppManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class RateAppManager {
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate let correctSubmissionsThreshold = 4
    
    fileprivate let showRateLaterPressedDateKey = "showRateLaterPressedDateKey"
    
    fileprivate let correctSubmissionsCountKey = "correctSubmissionsCountKey"
    
    fileprivate let neverShowRateAlertKey = "neverShowRateAlertKey"
    
    
    fileprivate var showRateLaterPressedDate: TimeInterval? {
        get {
            return defaults.value(forKey: showRateLaterPressedDateKey) as? TimeInterval
        }
        
        set(value) {
            defaults.set(value, forKey: showRateLaterPressedDateKey)
            defaults.synchronize()
        }
    }
    
    fileprivate var neverShowRateAlert: Bool {
        get {
            return defaults.value(forKey: neverShowRateAlertKey) as? Bool ?? false
        }
        
        set(value) {
            defaults.set(value, forKey: neverShowRateAlertKey)
            defaults.synchronize()
        }
    }

    
    fileprivate var correctSubmissionsCount: Int {
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
