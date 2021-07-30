//
//  TooltipDefaultsManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 23.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TooltipDefaultsManager {
    static let shared = TooltipDefaultsManager()

    private init() {}

    private let defaults = UserDefaults.standard

    private let didShowOnLessonDownloadsKey = "didShowOnLessonDownloadsKey"
    private let didShowOnHomeContinueLearningKey = "didShowOnHomeContinueLearningKey"
    private let didShowOnStreaksSwitchInProfileKey = "didShowOnStreaksSwitchInProfileKey"
    private let didShowInVideoPlayerKey = "didShowInVideoPlayerKey"
    private let didShowForCodeEditorKey = "didShowForCodeEditorKey"
    private let didShowOnPersonalDeadlinesButtonKey = "didShowOnPersonalDeadlinesButtonKey"
    private let didShowOnFullscreenCodeQuizTabRunKey = "didShowOnFullscreenCodeQuizTabRunKey"

    var didShowOnLessonDownloads: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnLessonDownloadsKey)
        }

        get {
            defaults.value(forKey: didShowOnLessonDownloadsKey) as? Bool ?? false
        }
    }

    var didShowOnHomeContinueLearning: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnHomeContinueLearningKey)
        }

        get {
            defaults.value(forKey: didShowOnHomeContinueLearningKey) as? Bool ?? false
        }
    }

    var didShowOnStreaksSwitchInProfile: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnStreaksSwitchInProfileKey)
        }

        get {
            defaults.value(forKey: didShowOnStreaksSwitchInProfileKey) as? Bool ?? false
        }
    }

    var didShowInVideoPlayer: Bool {
        set(value) {
            defaults.set(value, forKey: didShowInVideoPlayerKey)
        }

        get {
            defaults.value(forKey: didShowInVideoPlayerKey) as? Bool ?? false
        }
    }

    var didShowForCodeEditor: Bool {
        set(value) {
            defaults.set(value, forKey: didShowForCodeEditorKey)
        }

        get {
            defaults.value(forKey: didShowForCodeEditorKey) as? Bool ?? false
        }
    }

    var didShowOnPersonalDeadlinesButton: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnPersonalDeadlinesButtonKey)
        }

        get {
            defaults.value(forKey: didShowOnPersonalDeadlinesButtonKey) as? Bool ?? false
        }
    }

    var didShowOnFullscreenCodeQuizTabRun: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnFullscreenCodeQuizTabRunKey)
        }

        get {
            defaults.value(forKey: didShowOnFullscreenCodeQuizTabRunKey) as? Bool ?? false
        }
    }
}
