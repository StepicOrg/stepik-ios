//
//  CodePlaygroundManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class CodePlaygroundManager {
    typealias Autocomplete = (suggestions: [String], prefix: String)
    typealias AnalysisResult = (text: String, position: Int, autocomplete: Autocomplete?)
    typealias Changes = (isInsertion: Bool, changes: String)

    let closers: [String: String] = ["{": "}", "[": "]", "(": ")", "\"": "\"", "'": "'"]

    let allowedCharacters: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_"

    var suggestionsController: CodeSuggestionsTableViewController?
    var isSuggestionsViewPresented: Bool { self.suggestionsController != nil }

    /// Detects the changes string between currentText and previousText.
    /// All changes should be a substring inserted somewhere into the string.
    func getChangesSubstring(currentText: String, previousText: String) -> Changes {
        var maxString = ""
        var minString = ""
        var isInsertion = true

        // Determine if something was deleted or inserted
        if currentText.count > previousText.count {
            maxString = currentText
            minString = previousText
            isInsertion = true
        } else {
            maxString = previousText
            minString = currentText
            isInsertion = false
        }

        // Search for the beginning of the changed substring
        var changesBeginningOffset = 0
        while changesBeginningOffset < minString.count
            && minString[minString.index(minString.startIndex, offsetBy: changesBeginningOffset)]
            == maxString[maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset)] {
            changesBeginningOffset += 1
        }

        minString.removeSubrange(
            minString.startIndex..<minString.index(minString.startIndex, offsetBy: changesBeginningOffset)
        )
        maxString.removeSubrange(
            maxString.startIndex..<maxString.index(maxString.startIndex, offsetBy: changesBeginningOffset)
        )

        // Search for the ending of the changed substring
        var changesEndingOffset = 0
        while changesEndingOffset < minString.count
            && minString[minString.index(minString.index(before: minString.endIndex), offsetBy: -changesEndingOffset)]
            == maxString[maxString.index(maxString.index(before: maxString.endIndex), offsetBy: -changesEndingOffset)] {
            changesEndingOffset += 1
        }

        if !minString.isEmpty {
            minString.removeSubrange(
                minString.index(
                    minString.index(before: minString.endIndex),
                    offsetBy: -changesEndingOffset + 1
                )..<minString.endIndex
            )
        }
        if !maxString.isEmpty {
            maxString.removeSubrange(
                maxString.index(
                    maxString.index(before: maxString.endIndex),
                    offsetBy: -changesEndingOffset + 1
                )..<maxString.endIndex
            )
        }

        return (isInsertion: isInsertion, changes: maxString)
    }

    /// Detects if there should be made a new line after tab.
    private func shouldMakeTabLineAfter(
        symbol: Character,
        language: CodeLanguage
    ) -> (shouldMakeNewLine: Bool, paired: Bool) {
        switch language {
        case .python:
            return symbol == ":"
                ? (shouldMakeNewLine: true, paired: false)
                : (shouldMakeNewLine: false, paired: false)
        case .c, .cpp11, .cpp, .java, .java8, .java9, .java11, .cs, .kotlin, .swift:
            return symbol == "{"
                ? (shouldMakeNewLine: true, paired: true)
                : (shouldMakeNewLine: false, paired: false)
        default:
            return (shouldMakeNewLine: false, paired: false)
        }
    }

    /// Returns token between cursor position.
    /// - Parameters:
    ///   - text: The text from which token will be located.
    ///   - cursorPosition: The cursor position within provided text.
    private func getCurrentToken(text: String, cursorPosition: Int) -> String {
        guard cursorPosition >= 0 && cursorPosition <= text.count else {
            return ""
        }

        var offsetBefore = 0
        while let character = text[safe: (cursorPosition - offsetBefore - 1)],
              self.allowedCharacters.contains(character) {
            offsetBefore += 1
        }

        var offsetAfter = 0
        while let character = text[safe: (cursorPosition + offsetAfter)],
              self.allowedCharacters.contains(character) {
            offsetAfter += 1
        }

        let beforeCursorString = text[safe: (cursorPosition - offsetBefore)..<cursorPosition] ?? ""
        let afterCursorString = text[safe: cursorPosition..<(cursorPosition + offsetAfter)] ?? ""

        return beforeCursorString + afterCursorString
    }

    private func checkNextLineInsertion(
        currentText: String,
        previousText: String,
        cursorPosition: Int,
        language: CodeLanguage,
        tabSize: Int,
        changes: Changes
    ) -> AnalysisResult? {
        guard changes.isInsertion && changes.changes == "\n" else {
            return nil
        }

        var text = currentText
        let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)

        guard cursorIndex > text.startIndex else {
            return nil
        }

        // Searching previous \n or beginning of the string
        let firstPart = String(text[..<text.index(before: cursorIndex)])
        if let indexOfLineEndBefore = firstPart.lastIndexOf("\n") {
            // Extracting previous line before \n
            let indexAfterEndOfLine = firstPart.index(
                after: firstPart.index(firstPart.startIndex, offsetBy: indexOfLineEndBefore)
            )
            let line = String(firstPart[indexAfterEndOfLine...])

            // Counting spaces in the beginning to know the offset
            var spacesCount = 0
            for character in line {
                if character == " " {
                    spacesCount += 1
                } else {
                    break
                }
            }
            let offset = spacesCount

            // Searching for the last non-space symbol in the string to know if we need to do more than just return
            var characterBeforeEndline: Character?
            for character in line.reversed() {
                if character == " " {
                    continue
                } else {
                    characterBeforeEndline = character
                    break
                }
            }

            // Checking if there is any character before endline (it's not an empty or all-spaces line)
            if let char = characterBeforeEndline {
                let shouldTab = self.shouldMakeTabLineAfter(symbol: char, language: language)
                if shouldTab.shouldMakeNewLine {
                    if shouldTab.paired {
                        let spacesString = String(repeating: " ", count: offset + tabSize)
                            + "\n"
                            + String(repeating: " ", count: offset)
                        text.insert(
                            contentsOf: spacesString,
                            at: currentText.index(currentText.startIndex, offsetBy: cursorPosition)
                        )
                        return (text: text, position: cursorPosition + offset + tabSize, autocomplete: nil)
                    } else {
                        let spacesString = String(repeating: " ", count: offset + tabSize)
                        text.insert(
                            contentsOf: spacesString,
                            at: currentText.index(currentText.startIndex, offsetBy: cursorPosition)
                        )
                        return (text: text, position: cursorPosition + offset + tabSize, autocomplete: nil)
                    }
                }
            }

            // Returning with just the spaces and offset
            let spacesString = String(repeating: " ", count: offset)
            text.insert(
                contentsOf: spacesString,
                at: currentText.index(currentText.startIndex, offsetBy: cursorPosition)
            )

            return (text: text, position: cursorPosition + offset, autocomplete: nil)
        } else {
            return (text: text, position: cursorPosition, autocomplete: nil)
        }
    }

    private func checkPaired(
        currentText: String,
        previousText: String,
        cursorPosition: Int,
        language: CodeLanguage,
        tabSize: Int,
        changes: Changes
    ) -> AnalysisResult? {
        guard changes.isInsertion,
              let closer = closers[changes.changes] else {
            return nil
        }

        var text = currentText

        // Check if there is text after the bracket, not a \n or whitespace
        let cursorIndex = text.index(text.startIndex, offsetBy: cursorPosition)
        if cursorIndex != text.endIndex {
            let textAfter = String(text[cursorIndex...])
            if let indexOfLineEndAfter = textAfter.indexOf("\n") {
                let line = String(textAfter[..<textAfter.index(textAfter.startIndex, offsetBy: indexOfLineEndAfter)])
                var onlySpaces = true
                for character in line {
                    if character != " " {
                        onlySpaces = false
                        break
                    }
                }

                if onlySpaces {
                    text.insert(
                        closer[closer.startIndex],
                        at: currentText.index(currentText.startIndex, offsetBy: cursorPosition)
                    )
                    return (text: text, position: cursorPosition, autocomplete: nil)
                }
            }
        } else {
            text.insert(
                closer[closer.startIndex],
                at: currentText.index(currentText.startIndex, offsetBy: cursorPosition)
            )
            return (text: text, position: cursorPosition, autocomplete: nil)
        }

        return nil
    }

    private func getAutocompleteSuggestions(
        currentText: String,
        previousText: String,
        cursorPosition: Int,
        language: CodeLanguage
    ) -> AnalysisResult? {
        // Getting current token of a string
        let token = self.getCurrentToken(text: currentText, cursorPosition: cursorPosition)

        if token.isEmpty {
            return nil
        }

        let suggestions = AutocompleteWords.autocompleteFor(token, language: language)

        return (
            text: currentText,
            position: cursorPosition,
            autocomplete: (suggestions: suggestions, prefix: token)
        )
    }

    /// Analyzes given text using parameters.
    func analyze(
        currentText: String,
        previousText: String,
        cursorPosition: Int,
        language: CodeLanguage,
        tabSize: Int
    ) -> AnalysisResult {
        let changes = self.getChangesSubstring(currentText: currentText, previousText: previousText)

        if let nextLineInsertionResult = self.checkNextLineInsertion(
            currentText: currentText,
            previousText: previousText,
            cursorPosition: cursorPosition,
            language: language,
            tabSize: tabSize,
            changes: changes
        ) {
            return nextLineInsertionResult
        }

        if let pairedCheckResult = self.checkPaired(
            currentText: currentText,
            previousText: previousText,
            cursorPosition: cursorPosition,
            language: language,
            tabSize: tabSize,
            changes: changes
        ) {
            return pairedCheckResult
        }

        if let autocompleteSuggestionsResult = self.getAutocompleteSuggestions(
            currentText: currentText,
            previousText: previousText,
            cursorPosition: cursorPosition,
            language: language
        ) {
            return autocompleteSuggestionsResult
        }

        return (text: currentText, position: cursorPosition, autocomplete: nil)
    }

    func countTabSize(text: String) -> Int {
        var minTabSize = 100

        text.enumerateLines { line, _ in
            var spacesBeforeFirstCharacter = 0

            for character in line {
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

    private func hideSuggestions() {
        // TODO: hide suggestions view here
        self.suggestionsController?.view.removeFromSuperview()
        self.suggestionsController?.removeFromParent()
        self.suggestionsController = nil
    }

    // TODO: Refactor code suggestion presentation.
    private func presentSuggestions(
        suggestions: [String],
        prefix: String,
        cursorPosition: Int,
        inViewController vc: UIViewController,
        textView: UITextView,
        suggestionsDelegate: CodeSuggestionDelegate
    ) {
        // TODO: If suggestions are presented, only change the data there, otherwise instantiate and add suggestions view
        if self.suggestionsController == nil {
            self.suggestionsController = CodeSuggestionsTableViewController(
                nibName: "CodeSuggestionsTableViewController",
                bundle: nil
            )
            vc.addChild(self.suggestionsController!)
            textView.addSubview(self.suggestionsController!.view)
            self.suggestionsController?.delegate = suggestionsDelegate
        }

        self.suggestionsController?.suggestions = suggestions
        self.suggestionsController?.prefix = prefix

        if let selectedRange = textView.selectedTextRange {
            // `caretRect` is in the `textView` coordinate space.
            let caretRect = textView.caretRect(for: selectedRange.end)

            var suggestionsFrameMinX = caretRect.minX
            var suggestionsFrameMinY = caretRect.maxY

            let suggestionsHeight = self.suggestionsController!.suggestionsHeight

            // Check if we need to move suggestionsFrame
            if suggestionsFrameMinY + suggestionsHeight > (textView.frame.maxY - textView.frame.origin.y) {
                suggestionsFrameMinY = caretRect.minY - suggestionsHeight
            }

            if suggestionsFrameMinX + 100 > (textView.frame.maxX - textView.frame.origin.x) {
                suggestionsFrameMinX = (textView.frame.maxX - textView.frame.origin.x - 102)
            }

            self.suggestionsController?.view.frame = CGRect(
                x: suggestionsFrameMinX,
                y: suggestionsFrameMinY,
                width: 100,
                height: suggestionsHeight
            )
        }
    }

    func textRangeFrom(position: Int, textView: UITextView) -> UITextRange {
        let firstCharacterPosition = textView.beginningOfDocument
        let characterPosition = textView.position(from: firstCharacterPosition, offset: position)!
        let characterRange = textView.textRange(from: characterPosition, to: characterPosition)!
        return characterRange
    }

    func insertAtCurrentPosition(symbols: String, textView: UITextView) {
        guard let selectedRange = textView.selectedTextRange else {
            return
        }

        let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
        var text = textView.text!
        text.insert(contentsOf: symbols, at: text.index(text.startIndex, offsetBy: cursorPosition))
        textView.text = text
        // Import here to update selectedTextRange before calling textViewDidChange #APPS-2352
        textView.selectedTextRange = self.textRangeFrom(position: cursorPosition + symbols.count, textView: textView)
        // Manually call textViewDidChange, becuase when manually setting the text of a UITextView with code,
        // the textViewDidChange: method does not get called.
        textView.delegate?.textViewDidChange?(textView)
    }

    func analyzeAndComplete(
        textView: UITextView,
        previousText: String,
        language: CodeLanguage,
        tabSize: Int,
        inViewController vc: UIViewController,
        suggestionsDelegate: CodeSuggestionDelegate
    ) {
        guard let selectedRange = textView.selectedTextRange else {
            return
        }

        let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)

        let analyzed = self.analyze(
            currentText: textView.text,
            previousText: previousText,
            cursorPosition: cursorPosition,
            language: language,
            tabSize: tabSize
        )

        if textView.text != analyzed.text {
            textView.text = analyzed.text
            textView.delegate?.textViewDidChange?(textView)
        }

        if textView.selectedTextRange != self.textRangeFrom(position: analyzed.position, textView: textView) {
            textView.selectedTextRange = self.textRangeFrom(position: analyzed.position, textView: textView)
        }

        if let autocomplete = analyzed.autocomplete {
            if autocomplete.suggestions.isEmpty {
                self.hideSuggestions()
            } else {
                self.presentSuggestions(
                    suggestions: autocomplete.suggestions,
                    prefix: autocomplete.prefix,
                    cursorPosition: analyzed.position,
                    inViewController: vc,
                    textView: textView,
                    suggestionsDelegate: suggestionsDelegate
                )
            }
        } else {
            self.hideSuggestions()
        }
    }
}
