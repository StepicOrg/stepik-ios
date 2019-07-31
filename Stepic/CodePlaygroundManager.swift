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

    let closers: [String: String] = ["{": "}", "[": "]", "(": ")", "\"": "\"", "'": "'"]

    typealias Autocomplete = (suggestions: [String], prefix: String)
    typealias AnalysisResult = (text: String, position: Int, autocomplete: Autocomplete?)
    typealias Changes = (isInsertion: Bool, changes: String)

    var suggestionsController: CodeSuggestionsTableViewController?
    var isSuggestionsViewPresented: Bool {
        return suggestionsController != nil
    }

    //Detects the changes string between currentText and previousText
    //!!!All changes should be a substring inserted somewhere into the string
    func getChangesSubstring(currentText: String, previousText: String) -> Changes {

        var maxString: String = ""
        var minString: String = ""
        var isInsertion: Bool = true

        //Understand, if something was deleted or inserted
        if currentText.count > previousText.count {
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
        while (changesBeginningOffset < minString.count) && (minString.characters[minString.index(minString.startIndex, offsetBy: changesBeginningOffset)] == maxString.characters[maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset)]) {
            changesBeginningOffset += 1
        }
        minString.removeSubrange(minString.startIndex..<minString.index(minString.startIndex, offsetBy: changesBeginningOffset))
        maxString.removeSubrange(maxString.startIndex..<maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset))

        //Searching for the ending of the changed substring
        var changesEndingOffset = 0
        while (changesEndingOffset < minString.count) && (minString.characters[minString.index(minString.index(before: minString.endIndex), offsetBy: -changesEndingOffset)] == maxString.characters[maxString.index(maxString.index(before: maxString.endIndex), offsetBy: -changesEndingOffset)]) {
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

    //Detects, if there should be made a new line after tab
    fileprivate func shouldMakeTabLineAfter(symbol: Character, language: CodeLanguage) -> (shouldMakeNewLine: Bool, paired: Bool) {
        switch language {
        case .python:
            return symbol == ":" ? (shouldMakeNewLine: true, paired: false) : (shouldMakeNewLine: false, paired: false)
        case .c, .cpp11, .cpp, .java, .java8, .java9, .java11, .cs, .kotlin:
            return symbol == "{" ? (shouldMakeNewLine: true, paired: true) : (shouldMakeNewLine: false, paired: false)
        default:
            return (shouldMakeNewLine: false, paired: false)
        }
    }

    let allowedCharacters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_"

    //Gets current token for text
    fileprivate func getCurrentToken(text: String, cursorPosition: Int) -> String {

        var offsetBefore = 0
        while (text.startIndex != text.index(text.startIndex, offsetBy: cursorPosition - offsetBefore) &&
            allowedCharacters.indexOf("\(text.characters[text.index(before: text.index(text.startIndex, offsetBy: cursorPosition - offsetBefore))])") != nil) {
            offsetBefore += 1
        }

        var offsetAfter = 0
        while (text.endIndex != text.index(text.startIndex, offsetBy: cursorPosition + offsetAfter) &&
            allowedCharacters.indexOf("\(text.characters[text.index(text.startIndex, offsetBy: cursorPosition + offsetAfter)])") != nil) {
                offsetAfter += 1
        }

        let token = text.substring(with: text.index(text.startIndex, offsetBy: cursorPosition - offsetBefore)..<text.index(text.startIndex, offsetBy: cursorPosition)) + text.substring(with: text.index(text.startIndex, offsetBy: cursorPosition)..<text.index(text.startIndex, offsetBy: cursorPosition + offsetAfter))

        return token
    }

    fileprivate func checkNextLineInsertion(currentText: String, previousText: String, cursorPosition: Int, language: CodeLanguage, tabSize: Int, changes: Changes) -> AnalysisResult? {

        if changes.isInsertion && changes.changes == "\n" {
            var text = currentText

            let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)

            guard cursorIndex > text.startIndex else {
                return nil
            }

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
                var characterBeforeEndline: Character?
                for character in line.reversed() {
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
                            return (text: text, position: cursorPosition + offset + tabSize, autocomplete: nil)
                        } else {
                            let spacesString = String(repeating: " ", count: offset + tabSize)
                            text.insert(contentsOf: spacesString.characters, at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                            return (text: text, position: cursorPosition + offset + tabSize, autocomplete: nil)
                        }
                    }
                }

                // returning with just the spaces and offset
                let spacesString = String(repeating: " ", count: offset)
                text.insert(contentsOf: spacesString.characters, at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                return (text: text, position: cursorPosition + offset, autocomplete: nil)
            } else {
                return (text: text, position: cursorPosition, autocomplete: nil)
            }
        }

        return nil
    }

    fileprivate func checkPaired(currentText: String, previousText: String, cursorPosition: Int, language: CodeLanguage, tabSize: Int, changes: Changes) -> AnalysisResult? {
        if changes.isInsertion {
            if let closer = closers[changes.changes] {
                var text = currentText

                //check, if there is text after the bracket, not a \n or whitespace
                let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)
                if cursorIndex != text.endIndex {
                    let textAfter = text.substring(from: cursorIndex)
                    if let indexOfLineEndAfter = textAfter.indexOf("\n") {
                        let line = textAfter.substring(to: textAfter.index(textAfter.startIndex, offsetBy: indexOfLineEndAfter))
                        var onlySpaces: Bool = true
                        for character in line.characters {
                            if character != " " {
                                onlySpaces = false
                                break
                            }
                        }

                        if onlySpaces {
                            text.insert(closer.characters[closer.startIndex], at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                            return (text: text, position: cursorPosition, autocomplete: nil)
                        }
                    }
                } else {
                    text.insert(closer.characters[closer.startIndex], at: currentText.index(currentText.startIndex, offsetBy: cursorPosition))
                    return (text: text, position: cursorPosition, autocomplete: nil)
                }
            }
        }
        return nil
    }

    fileprivate func getAutocompleteSuggestions(currentText: String, previousText: String, cursorPosition: Int, language: CodeLanguage) -> AnalysisResult? {
        //Getting current token of a string
        let token = getCurrentToken(text: currentText, cursorPosition: cursorPosition)

        if token != "" {
            let suggestions = AutocompleteWords.autocompleteFor(token, language: language)
            return (text: currentText, position: cursorPosition, autocomplete: (suggestions: suggestions, prefix: token))
        }
        return nil
    }

    //Analyzes given text using parameters
    func analyze(currentText: String, previousText: String, cursorPosition: Int, language: CodeLanguage, tabSize: Int) -> AnalysisResult {
        let changes = getChangesSubstring(currentText: currentText, previousText: previousText)

        if let nextLineInsertionResult = checkNextLineInsertion(currentText: currentText, previousText: previousText, cursorPosition: cursorPosition, language: language, tabSize: tabSize, changes: changes) {
            return nextLineInsertionResult
        }
        if let pairedCheckResult = checkPaired(currentText: currentText, previousText: previousText, cursorPosition: cursorPosition, language: language, tabSize: tabSize, changes: changes) {
            return pairedCheckResult
        }
        if let autocompleteSuggestionsResult = getAutocompleteSuggestions(currentText: currentText, previousText: previousText, cursorPosition: cursorPosition, language: language) {
            return autocompleteSuggestionsResult
        }

        return (text: currentText, position: cursorPosition, autocomplete: nil)
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

    fileprivate func hideSuggestions() {
        //TODO: hide suggestions view here
        suggestionsController?.view.removeFromSuperview()
        suggestionsController?.removeFromParent()
        suggestionsController = nil
    }

    // TODO: Refactor code suggestion presentation.
    fileprivate func presentSuggestions(suggestions: [String], prefix: String, cursorPosition: Int, inViewController vc: UIViewController, textView: UITextView, suggestionsDelegate: CodeSuggestionDelegate) {
        //TODO: If suggestions are presented, only change the data there, otherwise instantiate and add suggestions view
        if suggestionsController == nil {
            suggestionsController = CodeSuggestionsTableViewController(nibName: "CodeSuggestionsTableViewController", bundle: nil)
            vc.addChild(suggestionsController!)
            textView.addSubview(suggestionsController!.view)
            suggestionsController?.delegate = suggestionsDelegate
        }

        suggestionsController?.suggestions = suggestions
        suggestionsController?.prefix = prefix

        if let selectedRange = textView.selectedTextRange {
            // `caretRect` is in the `textView` coordinate space.
            let caretRect = textView.caretRect(for: selectedRange.end)

            var suggestionsFrameMinX = caretRect.minX
            var suggestionsFrameMinY = caretRect.maxY

            let suggestionsHeight = suggestionsController!.suggestionsHeight

            //check if we need to move suggestionsFrame
            if suggestionsFrameMinY + suggestionsHeight > (textView.frame.maxY - textView.frame.origin.y) {
                suggestionsFrameMinY = caretRect.minY - suggestionsHeight
            }

            if suggestionsFrameMinX + 100 > (textView.frame.maxX - textView.frame.origin.x) {
                suggestionsFrameMinX = (textView.frame.maxX - textView.frame.origin.x - 102)
            }

            let rect = CGRect(x: suggestionsFrameMinX, y: suggestionsFrameMinY, width: 100, height: suggestionsHeight)
            suggestionsController?.view.frame = rect
        }
    }

    func textRangeFrom(position: Int, textView: UITextView) -> UITextRange {
        let firstCharacterPosition = textView.beginningOfDocument
        let characterPosition = textView.position(from: firstCharacterPosition, offset: position)!
        let characterRange = textView.textRange(from: characterPosition, to: characterPosition)!
        return characterRange
    }

    func insertAtCurrentPosition(symbols: String, textView: UITextView) {
        if let selectedRange = textView.selectedTextRange {
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            var text = textView.text!
            text.insert(contentsOf: symbols.characters, at: text.index(text.startIndex, offsetBy: cursorPosition))
            textView.text = text
            textView.selectedTextRange = textRangeFrom(position: cursorPosition + symbols.count, textView: textView)
        }
    }

    func analyzeAndComplete(textView: UITextView, previousText: String, language: CodeLanguage, tabSize: Int, inViewController vc: UIViewController, suggestionsDelegate: CodeSuggestionDelegate) {
        if let selectedRange = textView.selectedTextRange {
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)

            let analyzed = analyze(currentText: textView.text, previousText: previousText, cursorPosition: cursorPosition, language: language, tabSize: tabSize)

            if textView.text != analyzed.text {
                textView.text = analyzed.text
            }
            if textView.selectedTextRange != textRangeFrom(position: analyzed.position, textView: textView) {
                textView.selectedTextRange = textRangeFrom(position: analyzed.position, textView: textView)
            }
            if let autocomplete = analyzed.autocomplete {
                if autocomplete.suggestions.count == 0 {
                    hideSuggestions()
                } else {
                    presentSuggestions(suggestions: autocomplete.suggestions, prefix: autocomplete.prefix, cursorPosition: analyzed.position, inViewController: vc, textView: textView, suggestionsDelegate: suggestionsDelegate)
                }
            } else {
                hideSuggestions()
            }
        }
    }
}
