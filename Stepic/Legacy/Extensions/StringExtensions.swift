//
//  StringExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

extension String {
    func indexOf(_ target: String) -> Int? {
        if let range = self.range(of: target) {
            return self.distance(from: startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }

    func lastIndexOf(_ target: String) -> Int? {
        if let range = self.range(of: target, options: .backwards) {
            return self.distance(from: startIndex, to: range.lowerBound)
        } else {
            return nil
        }
    }
}
