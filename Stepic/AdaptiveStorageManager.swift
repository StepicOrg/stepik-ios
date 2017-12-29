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

    func canOpenInAdaptiveMode(courseId: Int) -> Bool {
        let adaptiveSupportedCourses = self.isAdaptiveModeEnabled ? StepicApplicationsInfo.adaptiveSupportedCourses : []
        return adaptiveSupportedCourses.contains(courseId)
    }
}
