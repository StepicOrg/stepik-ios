//
//  CodePlaygroundManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CodePlaygroundManager {
    init() {}

    //All changes should be a substring inserted somewhere into the string
    func getChangesSubstring(currentText: String, previousText: String) -> (isInsertion: Bool, changes: String) {
        
        var maxString: String = ""
        var minString: String = ""
        var isInsertion: Bool = true
        
        if currentText.characters.count > previousText.characters.count {
            maxString = currentText
            minString = previousText
            isInsertion = true
        } else {
            maxString = previousText
            minString = currentText
            isInsertion = false
        }
        
        var changesBeginningOffset = 0
        while (changesBeginningOffset < minString.characters.count) && (minString.characters[minString.index(minString.startIndex, offsetBy: changesBeginningOffset)] == maxString.characters[maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset)]) {
            changesBeginningOffset += 1
        }
        minString.removeSubrange(minString.startIndex..<minString.index(minString.startIndex, offsetBy: changesBeginningOffset))
        maxString.removeSubrange(maxString.startIndex..<maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset))

        
        var changesEndingOffset = 0
        while (changesEndingOffset < minString.characters.count) && (minString.characters[minString.index(minString.index(before: minString.endIndex), offsetBy: -changesEndingOffset)] == maxString.characters[maxString.index(maxString.index(before: maxString.endIndex), offsetBy: -changesEndingOffset)]) {
            changesEndingOffset += 1
        }
        if minString != "" {
            minString.removeSubrange(minString.index(minString.index(before: minString.endIndex), offsetBy: -changesEndingOffset + 1)..<minString.endIndex)
        }
        if maxString != "" {
            maxString.removeSubrange(maxString.index(maxString.index(before: maxString.endIndex), offsetBy: -changesEndingOffset + 1)..<maxString.endIndex)
        }

        return (isInsertion: isInsertion, changes: maxString)
        
    }
    
    let closers : [String: String] = ["{" : "}", "[" : "]", "(" : ")", "\"" : "\"", "'" : "'"]
    
    func analyze(currentText: String, previousText: String, cursorPosition: Int, language: String) -> (text: String, position: Int) {
        let changes = getChangesSubstring(currentText: currentText, previousText: previousText)
        
        var text = currentText
        
        if changes.isInsertion {
            if let closer = closers[changes.changes] {
                text.insert(closer.characters[closer.startIndex], at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                return (text: text, position: cursorPosition)
            }
        }
        return (text: currentText, position: cursorPosition)
    }
}
