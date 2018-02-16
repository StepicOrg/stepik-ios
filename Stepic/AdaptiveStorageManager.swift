//
//  AdaptiveStorageManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AdaptiveStorageManager {
    static let shared = AdaptiveStorageManager()

    let defaults = UserDefaults.standard
    private let adaptiveModeKey = "useAdaptiveMode"
    private let adaptiveOnboardingPassedKey = "adaptiveOnboardingPassed"

    var isAdaptiveModeEnabled: Bool {
        get {
            if let value = defaults.object(forKey: adaptiveModeKey) as? Bool {
                return value
            } else {
                defaults.set(true, forKey: adaptiveModeKey)
                return true
            }
        }
        set {
            defaults.set(newValue, forKey: adaptiveModeKey)
        }
    }

    var isAdaptiveOnboardingPassed: Bool {
        get {
            return defaults.bool(forKey: adaptiveOnboardingPassedKey)
        }
        set {
            defaults.set(newValue, forKey: adaptiveOnboardingPassedKey)
        }
    }

    func canOpenInAdaptiveMode(courseId: Int) -> Bool {
        let adaptiveSupportedCourses = self.isAdaptiveModeEnabled ? RemoteConfig.shared.supportedInAdaptiveModeCourses : []
        return adaptiveSupportedCourses.contains(courseId)
    }
}
