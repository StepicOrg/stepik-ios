//
//  RatingHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class RatingHelper {
    static func getLevel(for rating: Int) -> Int {
        return rating < 5 ? 1 : 2 + Int(log(Double(rating) / 5.0) / log(2.0))
    }

    static func getRating(for level: Int) -> Int {
        return level == 0 ? 0 : (level == 1 ? 5 : 5 * Int(pow(2.0, Double(level - 1))))
    }
}
