//
//  Numbers.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import CoreGraphics
import Foundation

public extension Int {
    /// SwiftRandom extension
    static func random(lower: Int = 0, _ upper: Int = 100) -> Int {
        lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

public extension Float {
    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Float {
        Float(arc4random()) / 0xFFFFFFFF
    }

    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    static func random(min: Float, max: Float) -> Float {
        Float.random * (max - min) + min
    }
}

public extension CGFloat {
    /// Randomly returns either 1.0 or -1.0.
    static var randomSign: CGFloat {
        (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: CGFloat {
        CGFloat(Float.random)
    }

    /// Random CGFloat between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random CGFloat point number between 0 and n max
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        CGFloat.random * (max - min) + min
    }
}
