//
//  RatingManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class RatingManager {
    static let shared = RatingManager()
    
    private let ratingKey = "rating"
    private let streakKey = "streak"
    let defaults = UserDefaults.standard
    
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
