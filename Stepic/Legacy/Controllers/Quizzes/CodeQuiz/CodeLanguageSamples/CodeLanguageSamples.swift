import Foundation

enum CodeLanguageSamples {
    private static let samplesDictionary: [String: String] = {
        guard let path = Bundle.main.path(forResource: "code-language-samples", ofType: "plist"),
              let result = NSDictionary(contentsOfFile: path) as? [String: String]
        else {
            return [:]
        }
        return result
    }()

    private static let python = samplesDictionary[Key.python.rawValue]
    private static let cpp = samplesDictionary[Key.cpp.rawValue]
    private static let haskell = samplesDictionary[Key.haskell.rawValue]
    private static let java = samplesDictionary[Key.java.rawValue]
    private static let octave = samplesDictionary[Key.octave.rawValue]
    private static let assembler = samplesDictionary[Key.assembler.rawValue]
    private static let shell = samplesDictionary[Key.shell.rawValue]
    private static let rust = samplesDictionary[Key.rust.rawValue]
    private static let r = samplesDictionary[Key.r.rawValue]
    private static let ruby = samplesDictionary[Key.ruby.rawValue]
    private static let clojure = samplesDictionary[Key.clojure.rawValue]
    private static let cs = samplesDictionary[Key.cs.rawValue]
    private static let javascript = samplesDictionary[Key.javascript.rawValue]
    private static let scala = samplesDictionary[Key.scala.rawValue]
    private static let kotlin = samplesDictionary[Key.kotlin.rawValue]
    private static let go = samplesDictionary[Key.go.rawValue]
    private static let pascal = samplesDictionary[Key.pascal.rawValue]
    private static let perl = samplesDictionary[Key.perl.rawValue]
    private static let sql = samplesDictionary[Key.sql.rawValue]
    private static let swift = samplesDictionary[Key.swift.rawValue]
    private static let php = samplesDictionary[Key.php.rawValue]
    private static let julia = samplesDictionary[Key.julia.rawValue]
    private static let dart = samplesDictionary[Key.dart.rawValue]

    static func sample(for language: CodeLanguage) -> String {
        let sample: String = { () -> String? in
            switch language {
            case .python, .python31:
                return python
            case .cpp, .cpp11, .c, .cValgrind:
                return cpp
            case .haskell, .haskell7, .haskell8, .haskell88:
                return haskell
            case .java, .java8, .java9, .java11, .java17:
                return java
            case .octave:
                return octave
            case .asm32, .asm64:
                return assembler
            case .shell:
                return shell
            case .rust:
                return rust
            case .r:
                return r
            case .ruby:
                return ruby
            case .clojure:
                return clojure
            case .cs, .csMono:
                return cs
            case .javascript:
                return javascript
            case .scala, .scala3:
                return scala
            case .kotlin:
                return kotlin
            case .go:
                return go
            case .pascal:
                return pascal
            case .perl:
                return perl
            case .sql:
                return sql
            case .swift:
                return swift
            case .php:
                return php
            case .julia:
                return julia
            case .dart:
                return dart
            }
        }() ?? ""
        return sample
    }

    private enum Key: String {
        case python
        case cpp
        case haskell
        case java
        case octave
        case assembler
        case shell
        case rust
        case r
        case ruby
        case clojure
        case cs
        case javascript
        case scala
        case kotlin
        case go
        case pascal
        case perl
        case sql
        case swift
        case php
        case julia
        case dart
    }
}
