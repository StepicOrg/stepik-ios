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
    
    static func incrementRating(_ value: Int) -> Int {
        let lastValue = UserDefaults.standard.integer(forKey: ratingKey)
        UserDefaults.standard.set(lastValue + value, forKey: ratingKey)
        
        return lastValue + value
    }
    
    static func retrieveRating() -> Int {
        return UserDefaults.standard.integer(forKey: ratingKey)
    }
    
    static func getLevel(for rating: Int) -> Int {
        if rating < 1 { return 0 }
        if rating < 2 { return 1 }
        if rating < 5 { return 2 }
        return 3 + Int(log(Double(rating) / 5.0) / log(2.0))
    }
    
    static func getRating(for level: Int) -> Int {
        if level == 1 { return 1 }
        if level == 2 { return 2 }
        if level == 3 { return 5 }
        return 5 * Int(pow(2.0, Double(level - 3)))
    }
}
