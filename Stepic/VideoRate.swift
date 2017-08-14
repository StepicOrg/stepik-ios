//
//  VideoRate.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

enum VideoRate: Float {
    case verySlow = 0.5
    case slow = 0.75
    case normal = 1
    case slightlyFast = 1.25
    case fast = 1.5
    case veryFast = 1.75
    case doubleFast = 2.0

    static var allValues: [VideoRate] {
        get {
            return [verySlow, slow, normal, slightlyFast, fast, veryFast, doubleFast]
        }
    }

    //If the value is a maximal rate, it cyclically gets the lowest one
    var nextValue: VideoRate {
        get {
            if let index = VideoRate.allValues.index(of: self) {
                if index < VideoRate.allValues.count - 1 {
                    return VideoRate.allValues[index + 1]
                } else {
                    return VideoRate.allValues[index]
                }
            }
            //Should never come here
            return self
        }
    }

    var description: String {
        return "\(self.rawValue)"
    }
}
