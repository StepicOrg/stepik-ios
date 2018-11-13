//
//  AutocompleteWords.swift
//  Stepic
//
//  Created by Ostrenkiy on 09.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

struct AutocompleteWords {

    private static let suggestionsFilename = "autocomplete_suggestions"

    static func autocompleteFor(_ text: String, language: CodeLanguage) -> [String] {
        var suggestions: [String] = []

        switch language {
        case .python:
            suggestions = python
            break
        case .cpp, .cpp11:
            suggestions = cpp
            break
        case .cs:
            suggestions = cs
            break
        case .java, .java8, .java9, .java11:
            suggestions = java
            break
        case .javascript:
            suggestions = js
            break
        case .ruby:
            suggestions = ruby
            break
        case .sql:
            suggestions = sql
        case .haskell, .haskell7, .haskell8:
            suggestions = haskell
        case .r:
            suggestions = r
        case .kotlin:
            suggestions = kotlin
        default:
            suggestions = []
            break
        }

        return suggestions.filter {
            $0.indexOf(text) == 0 && $0.count > text.count
        }
    }

    private static func loadSuggestionsFromFile(language: String) -> [String] {
        if let path = Bundle.main.path(forResource: suggestionsFilename, ofType: "plist"),
            let words = NSDictionary(contentsOfFile: path) as? [String: [String]] {
            return words[language] ?? []
        }
        return []
    }

    static let python = loadSuggestionsFromFile(language: "python")
    static let cpp = loadSuggestionsFromFile(language: "cpp")
    static let cs = loadSuggestionsFromFile(language: "cs")
    static let java = loadSuggestionsFromFile(language: "java")
    static let ruby = loadSuggestionsFromFile(language: "ruby")
    static let sql = loadSuggestionsFromFile(language: "sql")
    static let kotlin = loadSuggestionsFromFile(language: "kotlin")
    static let js = loadSuggestionsFromFile(language: "js")
    static let r = loadSuggestionsFromFile(language: "r")
    static let haskell = loadSuggestionsFromFile(language: "haskell")
}
