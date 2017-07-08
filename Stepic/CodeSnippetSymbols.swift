//
//  CodeSnippetSymbols.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

struct CodeSnippetSymbols {
    static let python : [String] = ["self", ":", "=", ".", "_", ",", "(", ")", "[", "]", "'", "*", "/", "+", "%", ">", "<", "and", "or", "not", "&", "|", "#", "\\", "{", "}", "@", "^", "~"]
    static let cpp : [String] = ["=", ".", "_", ",", "{", "}", "(", ")", "[", "]", "'", "\"", "*", "+", "/", "%", ">", "<", "&", "|", ":", "@", "^", "\\", "~"]
    static var java : [String] {
        return cpp
    }
    
    static func snippets(language: String) -> [String] {
        switch language {
        case "python3" :
            return python
        case "java", "java8" :
            return java
        default:
            return cpp
        }
    }
}
