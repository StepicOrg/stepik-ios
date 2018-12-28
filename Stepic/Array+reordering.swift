//
//  Array.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension Array {
    /// Reorder elements in custom order of transformed objects
    func reordered<T: Hashable & Equatable>(order: [T], transform: (Element) -> T) -> [Element] {
        var uniqueOrder: [T] = []
        order.forEach { item in
            if !uniqueOrder.contains(item) {
                uniqueOrder.append(item)
            }
        }

        let ordering = Dictionary<T, Int>(
            uniqueKeysWithValues: uniqueOrder.enumerated().map { ($1, $0) }
        )
        return self.sorted { a, b -> Bool in
            if let first = ordering[transform(a)],
               let second = ordering[transform(b)] {
                return first < second
            }
            return false
        }
    }
}
