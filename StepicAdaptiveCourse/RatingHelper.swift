//
//  RatingHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class RatingHelper {
    static let ratingKey = "rating"
    static let streakKey = "streak"
    static let defaults = UserDefaults.standard
    
    private static func incrementValue(_ value: Int, for key: String) -> Int {
        let lastValue = defaults.integer(forKey: key)
        defaults.set(lastValue + value, forKey: key)
        
        return lastValue + value
    }
    
    static func incrementRating(_ value: Int) -> Int {
        return RatingHelper.incrementValue(value, for: ratingKey)
    }
    
    static func incrementStreak(_ value: Int = 1) -> Int {
        return RatingHelper.incrementValue(value, for: streakKey)
    }
    
    static func retrieveRating() -> Int {
        return defaults.integer(forKey: ratingKey)
    }
    
    static func retrieveStreak() -> Int {
        return defaults.integer(forKey: streakKey)
    }
    
    static func getLevel(for rating: Int) -> Int {
        return rating < 5 ? 1 : 2 + Int(log(Double(rating) / 5.0) / log(2.0))
    }
    
    static func getRating(for level: Int) -> Int {
        return level == 0 ? 0 : (level == 1 ? 5 : 5 * Int(pow(2.0, Double(level - 1))))
    }
}
