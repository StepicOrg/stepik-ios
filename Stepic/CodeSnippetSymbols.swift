//
//  CodeSnippetSymbols.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

struct CodeSnippetSymbols {
    static let python: [String] = ["self", ":", "=", ".", "_", ",", "(", ")", "[", "]", "'", "*", "/", "+", "%", ">", "<", "and", "or", "not", "&", "|", "#", "\\", "{", "}", "@", "^", "~", ";"]
    static let cpp: [String] = ["=", ".", "_", ";", ",", "{", "}", "(", ")", "[", "]", "'", "\"", "*", "+", "/", "%", ">", "<", "&", "|", ":", "@", "^", "\\", "~"]
    static let sql: [String] = ["(", ")", "'", "`", ".", ",", "*", "/", "+", "-", ";", "<", ">", "=", "#", "@"]
    static var java: [String] {
        return cpp
    }

    static func snippets(language: CodeLanguage) -> [String] {
        switch language {
        case .python :
            return python
        case .java, .java8, .java9, .java11:
            return java
        case .sql:
            return sql
        default:
            return cpp
        }
    }
}
