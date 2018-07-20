//
//  Dictionary+SubscriptByIndex.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension Dictionary {
    // swiftlint:disable:this implicit_getter
    // Subscript is not mutating, get-only.
    subscript(idx: Int) -> (key: Key, value: Value) {
        get {
            return self[index(startIndex, offsetBy: idx)]
        }
    }
}
