//
//  AdaptiveRatingManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AdaptiveRatingManager {

    let courseId: Int

    private lazy var ratingKey: String = {
        "rating_\(self.courseId)"
    }()

    private lazy var streakKey: String = {
        "streak_\(self.courseId)"
    }()

    let defaults = UserDefaults.standard

    init(courseId: Int) {
        self.courseId = courseId
    }

    var rating: Int {
        get {
            return defaults.integer(forKey: ratingKey)
        }
        set(newValue) {
            updateValue(newValue, for: ratingKey)
        }
    }

    var streak: Int {
        get {
            return max(1, defaults.integer(forKey: streakKey))
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
