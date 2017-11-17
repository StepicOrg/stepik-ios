//
//  CodeLanguages.swift
//  Stepic
//
//  Created by Ostrenkiy on 26.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum CodeLanguage: String {
    case python = "python3"
    case cpp11 = "c++11"
    case cpp = "c++"
    case c = "c"
    case haskell = "haskell"
    case haskell7 = "haskell 7.10"
    case haskell8 = "haskell 8.0"
    case java = "java"
    case java8 = "java8"
    case octave = "octave"
    case asm32 = "asm32"
    case asm64 = "asm64"
    case shell = "shell"
    case rust = "rust"
    case r = "r"
    case ruby = "ruby"
    case clojure = "clojure"
    case cs = "mono c#"
    case javascript = "javascript"
    case scala = "scala"
    case kotlin = "kotlin"
    case go = "go"
    case pascal = "pascalabc"
    case perl = "perl"
    case sql = "sql"

    var highlightr: String {
        switch self {
        case .python:
            return "python"
        case .cpp, .cpp11, .c:
            return "cpp"
        case .haskell, .haskell7, .haskell8:
            return "haskell"
        case .java, .java8:
            return "java"
        case .octave:
            return "octave"
        case .asm32, .asm64:
            return "asmarm"
        case .shell:
            return "shell"
        case .rust:
            return "rust"
        case .r:
            return "r"
        case .ruby:
            return "ruby"
        case .clojure:
            return "clojure"
        case .cs:
            return "cs"
        case .javascript:
            return "javascript"
        case .scala:
            return "scala"
        case .kotlin:
            return "kotlin"
        case .go:
            return "go"
        case .pascal:
            return "delphi"
        case .perl:
            return "perl"
        case .sql:
            return "sql"
        }
    }

    var displayName: String {
        return rawValue
    }
}
