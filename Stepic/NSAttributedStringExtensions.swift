//
//  NSAttributedStringExtensions.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

extension NSAttributedString {
    func attributedStringByTrimmingNewlines() -> NSAttributedString {
        var attributedString = self
        while attributedString.string.first == "\n" {
            attributedString = attributedString.attributedSubstring(from: NSRange(location: 1, length: attributedString.string.count - 1))
        }
        while attributedString.string.last == "\n" {
            attributedString = attributedString.attributedSubstring(from: NSRange(location: 0, length: attributedString.string.count - 1))
        }
        return attributedString
    }
}
