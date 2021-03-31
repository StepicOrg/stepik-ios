//
//  AdaptiveRatingManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class AdaptiveRatingManager {
    let courseID: Int

    private lazy var ratingKey: String = {
        "rating_\(self.courseID)"
    }()

    private lazy var streakKey: String = {
        "streak_\(self.courseID)"
    }()

    let defaults = UserDefaults.standard

    init(courseID: Int) {
        self.courseID = courseID
    }

    var rating: Int {
        get {
            defaults.integer(forKey: ratingKey)
        }
        set(newValue) {
            updateValue(newValue, for: ratingKey)
        }
    }

    var streak: Int {
        get {
            max(1, defaults.integer(forKey: streakKey))
        }
        set(newValue) {
            updateValue(newValue, for: streakKey)
        }
    }

    private func updateValue(_ newValue: Int, for key: String) {
        defaults.set(newValue, forKey: key)
        defaults.synchronize()
    }
}
