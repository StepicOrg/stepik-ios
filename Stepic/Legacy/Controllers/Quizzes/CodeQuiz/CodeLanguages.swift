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
    case cs = "mono c#"
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
        case .cpp, .cpp11, .c:
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
        case .cs:
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
        case .cs:
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
        switch self {
        case .python, .python31:
            return "# comment\nprint(\"Hello World\")"
        case .cpp, .cpp11, .c:
            return "// comment\n\n#include <iostream>\n\nint main()\n{\n\tstd::cout << \"Hello World!\" << std::endl;\n}"
        case .haskell, .haskell7, .haskell8, .haskell88:
            return "-- comment\n\nmain = putStrLn \"Hello World\""
        case .java, .java8, .java9, .java11, .java17:
            return "// comment\n\nclass HelloWorld {\n\tstatic public void main(String args[]) {\n\t\tSystem.out.println(\"Hello World!\");\n\t}\n}"
        case .octave:
            return "# comment\nprintf(\"Hello World\\n\");"
        case .asm32, .asm64:
            return "; comment\n\nmov ax,cs\nmov ds,ax\nmov ah,9\nmov dx, offset Hello\nint 21h\nxor ax,ax\nint 21h\n\nHello:\n db \"Hello World!\",13,10,\"$\""
        case .shell:
            return "# comment\necho Hello World"
        case .rust:
            return "// comment\nfn main() {\n\tprintln!(\"Hello World!\");\n}"
        case .r:
            return "# comment\ncat(\"Hello world\\n\")"
        case .ruby:
            return "# comment\nputs \"Hello World!\""
        case .clojure:
            return "; comment\n\n(defn hello []\n  (println \"Hello world!\"))\n\n(hello)"
        case .cs:
            return "// comment\nclass HelloWorld\n{\n\tstatic void Main()\n\t{\n\t\tSystem.Console.WriteLine(\"Hello, World!\");\n\t}\n}"
        case .javascript:
            return "// comment\n\nconsole.log(\"Hello World\");"
        case .scala, .scala3:
            return "// comment\n\nobject HelloWorld extends App {\n  println(\"Hello world!\")\n}"
        case .kotlin:
            return "// comment\n\nfun main(args: Array<String>) {\n\tprintln(\"Hello, world!\")\n}"
        case .go:
            return "// comment\n\npackage main\nimport \"fmt\"\nfunc main() {\n\tfmt.Printf(\"Hello World\\n\")\n}"
        case .pascal:
            return "// comment\nProgram Hello_World;\n\n{$APPTYPE CONSOLE}\n\nBegin\n  WriteLn('Hello World');\nEnd."
        case .perl:
            return "# comment\nprint \"Hello World!\\n\";"
        case .sql:
            return "# comment\n\nSELECT 'Hello World';"
        case .swift:
            return "// comment\nprint(\"Hello World!\")"
        case .php:
            return "// comment\n\n<?php\n\necho 'Hello World';"
        case .julia:
            return "# comment\n\nprintln(\"Hello World\")"
        case .dart:
            return "void main() {\n\tprint('Hello, World!');\n}"
        }
    }

    // https://jupyterhub.int.stepik.org/user/ivan.magda/notebooks/ivan.magda/programming-languages-popularity.ipynb
    static var priorityOrder: [CodeLanguage] {
        [
            .python,
            .cpp11,
            .java11,
            .cs,
            .cpp,
            .java8,
            .c,
            .javascript,
            .kotlin,
            .r,
            .haskell,
            .scala,
            .pascal,
            .shell,
            .haskell8,
            .go,
            .asm64,
            .java,
            .asm32,
            .java9,
            .octave,
            .perl,
            .rust,
            .php,
            .ruby,
            .swift,
            .haskell7,
            .clojure,
            .julia
        ]
    }
}
