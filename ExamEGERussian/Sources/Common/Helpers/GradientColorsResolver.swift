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
        [UIColor(hex: 0xB12A5B), UIColor(hex: 0x9E206B)],
        [UIColor(hex: 0x2B5876), UIColor(hex: 0x4E4376)]
    ]

    private init() {
    }

    static func resolve<T: Hashable>(_ hash: T) -> [UIColor] {
        return colors[index(for: hash)]
    }

    private static func index<T: Hashable>(for key: T) -> Int {
        return hash(of: abs(key.hashValue)) % colors.count
    }

    private static func hash(of x: Int) -> Int {
        var h = x

        h = (h >> 16 ^ h) &* 0x45d9f3b
        h = (h >> 16 ^ h) &* 0x45d9f3b
        h = h >> 16 ^ h

        return h
    }
}
