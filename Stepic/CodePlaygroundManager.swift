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

    //Detects the changes string between currentText and previousText
    //!!!All changes should be a substring inserted somewhere into the string
    func getChangesSubstring(currentText: String, previousText: String) -> (isInsertion: Bool, changes: String) {
        
        var maxString: String = ""
        var minString: String = ""
        var isInsertion: Bool = true
        
        //Understand, if something was deleted or inserted
        if currentText.characters.count > previousText.characters.count {
            maxString = currentText
            minString = previousText
            isInsertion = true
        } else {
            maxString = previousText
            minString = currentText
            isInsertion = false
        }
        
        //Searching for the beginning of the changed substring
        var changesBeginningOffset = 0
        while (changesBeginningOffset < minString.characters.count) && (minString.characters[minString.index(minString.startIndex, offsetBy: changesBeginningOffset)] == maxString.characters[maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset)]) {
            changesBeginningOffset += 1
        }
        minString.removeSubrange(minString.startIndex..<minString.index(minString.startIndex, offsetBy: changesBeginningOffset))
        maxString.removeSubrange(maxString.startIndex..<maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset))

        //Searching for the ending of the changed substring
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
    
    //Detects, if there should be made a new line after tab
    fileprivate func shouldMakeTabLineAfter(symbol: Character, language: String) -> (shouldMakeNewLine: Bool, paired: Bool) {
        switch language {
        case "python3":
            return symbol == ":" ? (shouldMakeNewLine: true, paired: false) : (shouldMakeNewLine: false, paired: false)
        case "c", "c++11", "c++", "java", "java8", "mono c#":
            return symbol == "{" ? (shouldMakeNewLine: true, paired: true) : (shouldMakeNewLine: false, paired: false)
        default:
            return (shouldMakeNewLine: false, paired: false)
        }
    }
    
    //Analyzes given text using parameters
    func analyze(currentText: String, previousText: String, cursorPosition: Int, language: String, tabSize: Int) -> (text: String, position: Int) {
        let changes = getChangesSubstring(currentText: currentText, previousText: previousText)
        
        var text = currentText
        
        if changes.isInsertion {
            if let closer = closers[changes.changes] {
                text.insert(closer.characters[closer.startIndex], at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                return (text: text, position: cursorPosition)
            }
            
            if changes.changes == "\n" {
                let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)
                //searching previous \n or beginning of the string
                let firstPart = text.substring(to: text.index(before: cursorIndex))
                if let indexOfLineEndBefore = firstPart.lastIndexOf("\n") {
                    //extracting previous line before \n
                    let line = firstPart.substring(from: firstPart.index(after: firstPart.index(firstPart.startIndex, offsetBy: indexOfLineEndBefore)))
                    
                    //counting spaces in the beginning to know the offset
                    var spacesCount = 0
                    for character in line.characters {
                        if character == " " {
                            spacesCount += 1
                        } else {
                            break
                        }
                    }
                    let offset = spacesCount
                    
                    //searching for the last non-space symbol in the string to know if we need to do more than just return
                    var characterBeforeEndline : Character? = nil
                    for character in line.characters.reversed() {
                        if character == " " {
                            continue
                        } else {
                            characterBeforeEndline = character
                            break
                        }
                    }
                    
                    //Checking if there is any character before endline (it's not an empty or all-spaces line)
                    if let char = characterBeforeEndline {
                        let shouldTab = shouldMakeTabLineAfter(symbol: char, language: language)
                        if shouldTab.shouldMakeNewLine {
                            if shouldTab.paired {
                                let spacesString = String(repeating: " ", count: offset + tabSize) + "\n" + String(repeating: " ", count: offset)
                                text.insert(contentsOf: spacesString.characters, at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                                return (text: text, position: cursorPosition + offset + tabSize)
                            } else {
                                let spacesString = String(repeating: " ", count: offset + tabSize)
                                text.insert(contentsOf: spacesString.characters, at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                                return (text: text, position: cursorPosition + offset + tabSize)
                            }
                        }
                    }
                    
                    // returning with just the spaces and offset
                    let spacesString = String(repeating: " ", count: offset)
                    text.insert(contentsOf: spacesString.characters, at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                    return (text: text, position: cursorPosition + offset)
                    
                } else {
                    return (text: text, position: cursorPosition)
                }
            }
        }
        return (text: currentText, position: cursorPosition)
    }
    
    func countTabSize(text: String) -> Int {
        var minTabSize = 100
        text.enumerateLines {
            line, _ in
            var spacesBeforeFirstCharacter = 0
            for character in line.characters {
                if character == " " {
                    spacesBeforeFirstCharacter += 1
                } else {
                    break
                }
            }
            if spacesBeforeFirstCharacter > 0 && minTabSize > spacesBeforeFirstCharacter {
                minTabSize = spacesBeforeFirstCharacter
            }
        }
        if minTabSize == 100 {
            minTabSize = 4
        }
        return minTabSize
    }
}
