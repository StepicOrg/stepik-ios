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

    var didShowOnLessonDownloads: Bool {
        set(value) {
            defaults.set(value, forKey: didShowOnLessonDownloadsKey)
        }

        get {
//            return false
            return defaults.value(forKey: didShowOnLessonDownloadsKey) as? Bool ?? false
        }
    }

    var shouldShowLessonDownloadsTooltip: Bool {
        return !didShowOnLessonDownloads
    }
}
