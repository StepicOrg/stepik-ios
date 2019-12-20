//
//  VideoRate.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

enum VideoRate: Float, CaseIterable {
    case verySlow = 0.5
    case slow = 0.75
    case normal = 1
    case slightlyFast = 1.25
    case fast = 1.5
    case veryFast = 1.75
    case doubleFast = 2.0

    // If the value is a maximal rate, it cyclically gets the lowest one
    var nextValue: VideoRate {
        get {
            if let index = VideoRate.allCases.firstIndex(of: self) {
                if index < VideoRate.allCases.count - 1 {
                    return VideoRate.allCases[index + 1]
                } else {
                    return VideoRate.allCases[index]
                }
            }
            return self
        }
    }

    var description: String { "\(self.rawValue)" }
}
