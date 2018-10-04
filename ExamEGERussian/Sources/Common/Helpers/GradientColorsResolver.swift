//
//  GradientColorsResolver.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class GradientColorsResolver {
    private static let colors = [
        [UIColor(hex: 0x42275A), UIColor(hex: 0x734B6D)],
        [UIColor(hex: 0x516395), UIColor(hex: 0x4CA1AF)],
        [UIColor(hex: 0x2B5876), UIColor(hex: 0x4E4376)],
        [UIColor(hex: 0x2A6587), UIColor(hex: 0x66A69F)]
    ]

    private init() {
    }

    static func resolve<T: Hashable>(_ hash: T) -> [UIColor] {
        return colors[index(for: hash)]
    }

    private static func index<T: Hashable>(for key: T) -> Int {
        return abs(key.hashValue) % colors.count
    }
}
