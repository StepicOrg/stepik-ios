//
//  RangeExtension.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}
