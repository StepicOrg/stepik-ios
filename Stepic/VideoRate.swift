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
            var values : [VideoRate] = []
            var i : Float = 0.0
            while i <= 3.0 {
                if let rate = VideoRate(rawValue: i) {
                    values += [rate]
                }
                i += 0.05
            }
            return values
        }
    }
    
    
    //If the value is a maximal rate, it cyclically gets the lowest one
    var nextValue : VideoRate {
        get {
            var i : Float = self.rawValue
            while i <= 3.0 {
                if let rate = VideoRate(rawValue: i) {
                    return rate
                }
                i += 0.05
            }
            while i < self.rawValue {
                if let rate = VideoRate(rawValue: i) {
                    return rate
                }
                i += 0.05
            }
            return self
        }
    }
}