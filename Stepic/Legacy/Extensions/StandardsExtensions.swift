//
//  StandardsExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension Dictionary {
    mutating func merge<K, V>(_ dict: [K: V]) {
        for (key, value) in dict {
            self.updateValue(value as! Value, forKey: key as! Key)
        }
    }
}

extension Array {
    func shifted(by shiftAmount: Int) -> [Element] {
        guard self.count > 0, (shiftAmount % self.count) != 0 else {
            return self
        }

        let moduloShiftAmount = shiftAmount % self.count
        let negativeShift = shiftAmount < 0
        let effectiveShiftAmount = negativeShift ? moduloShiftAmount + self.count : moduloShiftAmount

        let shift: (Int) -> Int = {
            $0 + effectiveShiftAmount >= self.count
                ? $0 + effectiveShiftAmount - self.count
                : $0 + effectiveShiftAmount
        }

        return self
            .enumerated()
            .sorted(by: { shift($0.offset) < shift($1.offset) })
            .map { $0.element }
    }
}

// https://oleb.net/blog/2016/12/optionals-string-interpolation/
infix operator ???: NilCoalescingPrecedence

func ??? <T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    switch optional {
    case let value?:
        return String(describing: value)
    case nil:
        return defaultValue()
    }
}

func == <T: Equatable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return lhs == rhs
    case (.none, .none):
        return true
    default:
        return false
    }
}
