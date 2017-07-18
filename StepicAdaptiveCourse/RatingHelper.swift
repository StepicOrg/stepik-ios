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
        switch rating {
        case _ where rating < 1:
            return 0
        case _ where rating < 2:
            return 1
        case _ where rating < 5:
            return 2
        default:
            return 3 + Int(log(Double(rating) / 5.0) / log(2.0))
        }
    }
    
    static func getRating(for level: Int) -> Int {
        switch level {
        case 1:
            return 1
        case 2:
            return 2
        case 3:
            return 5
        default:
            return 5 * Int(pow(2.0, Double(level - 3)))
        }
    }
}
