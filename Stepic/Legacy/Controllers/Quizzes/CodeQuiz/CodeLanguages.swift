//
//  CodeLanguages.swift
//  Stepic
//
//  Created by Ostrenkiy on 26.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum CodeLanguage: String, CaseIterable {
    case python = "python3"
    case python31 = "python3.10"
    case cpp11 = "c++11"
    case cpp = "c++"
    case c = "c"
    case cValgrind = "c_valgrind"
    case haskell = "haskell"
    case haskell7 = "haskell 7.10"
    case haskell8 = "haskell 8.0"
    case haskell88 = "haskell 8.8"
    case java = "java"
    case java8 = "java8"
    case java9 = "java9"
    case java11 = "java11"
    case java17 = "java17"
    case octave = "octave"
    case asm32 = "asm32"
    case asm64 = "asm64"
    case shell = "shell"
    case rust = "rust"
    case r = "r"
    case ruby = "ruby"
    case clojure = "clojure"
    case cs = "c#"
    case csMono = "mono c#"
    case javascript = "javascript"
    case scala = "scala"
    case scala3 = "scala3"
    case kotlin = "kotlin"
    case go = "go"
    case pascal = "pascalabc"
    case perl = "perl"
    case sql = "sql"
    case swift = "swift"
    case php = "php"
    case julia = "julia"
    case dart = "dart"

    var highlightr: String {
        switch self {
        case .python, .python31:
            return "python"
        case .cpp, .cpp11, .c, .cValgrind:
            return "cpp"
        case .haskell, .haskell7, .haskell8, .haskell88:
            return "haskell"
        case .java, .java8, .java9, .java11, .java17:
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
        case .cs, .csMono:
            return "cs"
        case .javascript:
            return "javascript"
        case .scala, .scala3:
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
        case .swift:
            return "swift"
        case .php:
            return "php"
        case .julia:
            return "julia"
        case .dart:
            return "dart"
        }
    }

    var humanReadableName: String {
        switch self {
        case .python, .python31:
            return "Python"
        case .cpp, .cpp11, .c:
            return "C++"
        case .cValgrind:
            return "C (Valgrind)"
        case .haskell, .haskell7, .haskell8, .haskell88:
            return "Haskell"
        case .java, .java8, .java9, .java11, .java17:
            return "Java"
        case .octave:
            return "Octave"
        case .asm32, .asm64:
            return "ASM"
        case .shell:
            return "Shell"
        case .rust:
            return "Rust"
        case .r:
            return "R"
        case .ruby:
            return "Ruby"
        case .clojure:
            return "Clojure"
        case .cs, .csMono:
            return "C#"
        case .javascript:
            return "Javascript"
        case .scala, .scala3:
            return "Scala"
        case .kotlin:
            return "Kotlin"
        case .go:
            return "Go"
        case .pascal:
            return "Delphi"
        case .perl:
            return "Perl"
        case .sql:
            return "SQL"
        case .swift:
            return "Swift"
        case .php:
            return "PHP"
        case .julia:
            return "Julia"
        case .dart:
            return "Dart"
        }
    }

    var displayName: String { self.rawValue }

    var highlightrSample: String {
        CodeLanguageSamples.sample(for: self)
    }

    // https://jupyterhub.int.stepik.org/user/ivan.magda/notebooks/ivan.magda/programming-languages-popularity.ipynb
    static var priorityOrder: [CodeLanguage] {
        [
            .python,
            .java17,
            .kotlin,
            .cpp11,
            .cpp,
            .java8,
            .java11,
            .javascript,
            .go,
            .c,
            .java,
            .cs,
            .python31,
            .r,
            .php,
            .shell,
            .pascal,
            .haskell,
            .csMono,
            .ruby,
            .scala,
            .haskell8,
            .asm64,
            .swift,
            .haskell88,
            .asm32,
            .cValgrind,
            .java9,
            .rust,
            .octave,
            .dart,
            .perl,
            .haskell7,
            .clojure,
            .julia
        ]
    }
}
