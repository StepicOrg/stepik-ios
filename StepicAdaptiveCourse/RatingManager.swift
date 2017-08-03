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
    
    private func incrementValue(_ value: Int, for key: String) -> Int {
        let lastValue = defaults.integer(forKey: key)
        defaults.set(lastValue + value, forKey: key)
        
        return lastValue + value
    }
    
    func incrementRating(_ value: Int) -> Int {
        return incrementValue(value, for: ratingKey)
    }
    
    func incrementStreak(_ value: Int = 1) -> Int {
        return incrementValue(value, for: streakKey)
    }
    
    func retrieveRating() -> Int {
        return defaults.integer(forKey: ratingKey)
    }
    
    func retrieveStreak() -> Int {
        return defaults.integer(forKey: streakKey)
    }
}
