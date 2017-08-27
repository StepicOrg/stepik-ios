//
//  AchievementsHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AchievementsHelper {
    private static let achievementPrefix = "achievement_"
    private static let valueKey = "value"

    static let defaults = UserDefaults.standard

    static func save(_ value: Achievement) {
        let params = [
            valueKey: "\(value.progressValue)"
        ]
        defaults.set(params, forKey: "\(achievementPrefix)\(value.slug)")
    }

    static func restore(for slug: String) -> (progressValue: Int, _: Any?)? {
        guard let params = defaults.value(forKey: "\(achievementPrefix)\(slug)") as? [String: String] else {
            return nil
        }

        guard let progressValue = params[valueKey] else {
            return nil
        }

        return (progressValue: Int(progressValue)!, _: nil)
    }
}
