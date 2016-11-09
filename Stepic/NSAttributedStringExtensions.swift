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
        while attributedString.string.characters.first == "\n" {
            attributedString = attributedString.attributedSubstring(from: NSMakeRange(1, attributedString.string.characters.count - 1))
        }
        while attributedString.string.characters.last == "\n" {
            attributedString = attributedString.attributedSubstring(from: NSMakeRange(0, attributedString.string.characters.count - 1))
        }
        return attributedString
    }
}
