//
//  TooltipDefaultsManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 23.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class TooltipDefaultsManager {
    static let shared = TooltipDefaultsManager()
    private init() {}

    private let defaults = UserDefaults.standard

    private let didShowOnLessonDownloadsKey = "didShowOnLessonDownloadsKey"
    private let didShowOnHomeContinueLearningKey = "didShowOnHomeContinueLearningKey"
    private let didShowOnStreaksSwitchInProfileKey = "didShowOnStreaksSwitchInProfileKey"

    var didShowOnLessonDownloads: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnLessonDownloadsKey)
        }

        get {
            return defaults.value(forKey: didShowOnLessonDownloadsKey) as? Bool ?? false
        }
    }

    var didShowOnHomeContinueLearning: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnHomeContinueLearningKey)
        }

        get {
            return defaults.value(forKey: didShowOnHomeContinueLearningKey) as? Bool ?? false
        }
    }

    var didShowOnStreaksSwitchInProfile: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnStreaksSwitchInProfileKey)
        }

        get {
            return defaults.value(forKey: didShowOnStreaksSwitchInProfileKey) as? Bool ?? false
        }
    }

    var shouldShowOnHomeContinueLearning: Bool {
        return !didShowOnHomeContinueLearning
    }

    var shouldShowLessonDownloadsTooltip: Bool {
        return !didShowOnLessonDownloads
    }

    var shouldShowOnStreaksSwitchInProfile: Bool {
        return !didShowOnStreaksSwitchInProfile
    }
}
