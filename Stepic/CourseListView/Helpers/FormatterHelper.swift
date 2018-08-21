//
//  FormatterHelper.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum FormatterHelper {
    static func longNumber(_ number: Int) -> String {
        return number >= 1000
            ? "\(String(format: "%.1f", Double(number) / 1000.0))K"
            : "\(number)"
    }
}
