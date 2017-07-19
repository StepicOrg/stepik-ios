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
        switch rating {
        case _ where rating < 1:
            return 1
        case _ where rating < 2:
            return 2
        case _ where rating < 5:
            return 3
        default:
            return 4 + Int(log(Double(rating) / 5.0) / log(2.0))
        }
    }
    
    static func getRating(for level: Int) -> Int {
        switch level {
        case 1:
            return 0
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 5
        default:
            return 5 * Int(pow(2.0, Double(level - 4)))
        }
    }
}
