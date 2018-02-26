//
//  MigrationExtensions.swift
//  Adaptive 1838
//
//  Created by Vladislav Kiryukhin on 20.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension AdaptiveRatingManager {
    func migrate() {
        let oldRatingKey = "rating"
        let oldStreakKey = "streak"

        if let oldRating = defaults.object(forKey: oldRatingKey) as? Int {
            self.rating = oldRating
            defaults.removeObject(forKey: oldRatingKey)
        }

        if let oldStreak = defaults.object(forKey: oldStreakKey) as? Int {
            self.streak = oldStreak
            defaults.removeObject(forKey: oldStreakKey)
        }
    }
}

extension AdaptiveStatsManager {
    func migrate() {
        let oldStatsKey = "stats"
        let oldMaxStreakKey = "max_streak"

        if let oldStats = defaults.object(forKey: oldStatsKey) as? [String: String] {
            self.stats = stringDictToIntDict(oldStats)
            defaults.removeObject(forKey: oldStatsKey)
        }

        if let oldMaxStreak = defaults.object(forKey: oldMaxStreakKey) as? Int {
            self.maxStreak = oldMaxStreak
            defaults.removeObject(forKey: oldMaxStreakKey)
        }
    }
}

extension AdaptiveStorageManager {
    func migrate() {
        let oldKey = "isRatingOnboardingShown"

        if let oldValue = defaults.object(forKey: oldKey) as? Bool {
            self.isAdaptiveOnboardingPassed = oldValue
            defaults.removeObject(forKey: oldKey)
        }
    }
}
