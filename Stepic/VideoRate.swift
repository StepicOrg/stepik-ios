//
//  VideoRate.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

enum VideoRate: Float {
    case VerySlow = 0.5
    case Slow = 0.75
    case Normal = 1
    case SlightlyFast = 1.25
    case Fast = 1.5
    case VeryFast = 1.75
    case DoubleFast = 2.0
    
    static var allValues : [VideoRate] {
        get {
            return [VerySlow, Slow, Normal, SlightlyFast, Fast, VeryFast, DoubleFast]
        }
    }
    
    
    //If the value is a maximal rate, it cyclically gets the lowest one
    var nextValue : VideoRate {
        get {
            if let index = VideoRate.allValues.indexOf(self) {
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
    
    var description : String {
        return "\(self.rawValue)"
    }
}