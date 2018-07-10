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
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

extension Array {
    func shifted(by shiftAmount: Int) -> Array<Element> {
        guard self.count > 0, (shiftAmount % self.count) != 0 else { return self }

        let moduloShiftAmount = shiftAmount % self.count
        let negativeShift = shiftAmount < 0
        let effectiveShiftAmount = negativeShift ? moduloShiftAmount + self.count : moduloShiftAmount

        let shift: (Int) -> Int = { return $0 + effectiveShiftAmount >= self.count ? $0 + effectiveShiftAmount - self.count : $0 + effectiveShiftAmount }

        return self.enumerated().sorted(by: { shift($0.offset) < shift($1.offset) }).map { $0.element }
    }
}

// https://oleb.net/blog/2016/12/optionals-string-interpolation/
infix operator ???: NilCoalescingPrecedence

public func ??? <T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    switch optional {
    case let value?:
        return String(describing: value)
    case nil:
        return defaultValue()
    }
}
