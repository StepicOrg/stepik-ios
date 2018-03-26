//
//  AutocompleteWords.swift
//  Stepic
//
//  Created by Ostrenkiy on 09.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

struct AutocompleteWords {

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
        case .java, .java8:
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

    static let python = [
        "False",
        "class",
        "finally",
        "is",
        "return",
        "None",
        "continue",
        "for",
        "lambda",
        "try",
        "True",
        "def",
        "from",
        "nonlocal",
        "while",
        "and",
        "del",
        "global",
        "not",
        "with",
        "as",
        "elif",
        "if",
        "or",
        "yield",
        "assert",
        "else",
        "import",
        "pass",
        "print",
        "break",
        "except",
        "in",
        "raise"
    ]

    static let cpp = [
        "bool",
        "break",
        "case",
        "catch",
        "char",
        "class",
        "const",
        "cout",
        "cin",
        "endl",
        "include",
        "iostream",
        "continue",
        "default",
        "delete",
        "do",
        "double",
        "else",
        "enum",
        "extern",
        "false",
        "float",
        "for",
        "friend",
        "goto",
        "if",
        "inline",
        "int",
        "long",
        "mutable",
        "namespace",
        "new",
        "operator",
        "private",
        "protected",
        "public",
        "return",
        "short",
        "signed",
        "sizeof",
        "static",
        "string",
        "struct",
        "switch",
        "template",
        "this",
        "throw",
        "true",
        "try",
        "typedef",
        "typename",
        "union",
        "unsigned",
        "using",
        "virtual",
        "void",
        "while"
    ]

    static let cs = [
        "abstract",
        "base",
        "bool",
        "break",
        "byte",
        "case",
        "catch",
        "char",
        "checked",
        "class",
        "const",
        "continue",
        "decimal",
        "default",
        "delegate",
        "do",
        "double",
        "else",
        "enum",
        "event",
        "explicit",
        "extern",
        "false",
        "finally",
        "fixed",
        "float",
        "for",
        "foreach",
        "goto",
        "if",
        "implicit",
        "int",
        "interface",
        "internal",
        "lock",
        "long",
        "namespace",
        "new",
        "null",
        "object",
        "operator",
        "out",
        "override",
        "params",
        "private",
        "protected",
        "public",
        "readonly",
        "ref",
        "return",
        "sbyte",
        "sealed",
        "short",
        "sizeof",
        "stackalloc",
        "static",
        "string",
        "struct",
        "switch",
        "this",
        "throw",
        "true",
        "try",
        "typeof",
        "uint",
        "ulong",
        "unchecked",
        "unsafe",
        "ushort",
        "using",
        "virtual",
        "void",
        "volatile",
        "while",
        "set",
        "get",
        "var"
    ]

    static let java = [
        "abstract",
        "assert",
        "boolean",
        "break",
        "byte",
        "case",
        "catch",
        "char",
        "class",
        "const",
        "continue",
        "default",
        "do",
        "double",
        "else",
        "enum",
        "extends",
        "final",
        "finally",
        "float",
        "for",
        "goto",
        "if",
        "implements",
        "import",
        "instanceof",
        "int",
        "interface",
        "long",
        "native",
        "new",
        "package",
        "private",
        "protected",
        "public",
        "return",
        "short",
        "static",
        "super",
        "switch",
        "synchronized",
        "this",
        "throw",
        "throws",
        "try",
        "void",
        "volatile",
        "while",
        "false",
        "null",
        "true",
        "System",
        "out",
        "print",
        "println",
        "main",
        "String",
        "Math",
        "Scanner",
        "Thread",
        "ArrayList",
        "LinkedList",
        "HashMap",
        "HashSet",
        "Collections",
        "Iterator",
        "File",
        "Formatter",
        "Exception"
    ]

    static let ruby = [
        "and",
        "begin",
        "break",
        "case",
        "class",
        "def",
        "do",
        "else",
        "elsif",
        "each",
        "end",
        "true",
        "false",
        "for",
        "if",
        "in",
        "module",
        "next",
        "nil",
        "not",
        "or",
        "rescue",
        "retry",
        "return",
        "self",
        "super",
        "then",
        "undef",
        "unless",
        "until",
        "when",
        "while",
        "yield",
        "attr_accessor",
        "attr_reader",
        "attr_writer",
        "initialize",
        "new",
        "puts",
        "gets",
        "print",
        "Struct",
        "Math",
        "Time",
        "Proc",
        "File",
        "lambda",
        "Comparable",
        "Enumerable"
    ]

    static let sql = [
        "ADD",
        "ALL",
        "ALTER",
        "AND",
        "ANY",
        "APPLY",
        "AS",
        "ASC",
        "AUTHORIZATION",
        "BACKUP",
        "BEGIN",
        "BETWEEN",
        "BREAK",
        "BROWSE",
        "BULK",
        "BY",
        "CASCADE",
        "CASE",
        "CHECK",
        "CHECKPOINT",
        "CLOSE",
        "CLUSTERED",
        "COALESCE",
        "COLLATE",
        "COLUMN",
        "COMMIT",
        "COMPUTE",
        "CONNECT",
        "CONSTRAINT",
        "CONTAINS",
        "CONTAINSTABLE",
        "CONTINUE",
        "CONVERT",
        "CREATE",
        "CROSS",
        "CURRENT",
        "CURRENT_DATE",
        "CURRENT_TIME",
        "CURRENT_TIMESTAMP",
        "CURRENT_USER",
        "CURSOR",
        "DATABASE",
        "DBCC",
        "DEALLOCATE",
        "DECLARE",
        "DEFAULT",
        "DELETE",
        "DENY",
        "DESC",
        "DISK",
        "DISTINCT",
        "DISTRIBUTED",
        "DOUBLE",
        "DROP",
        "DUMMY",
        "DUMP",
        "ELSE",
        "END",
        "ERRLVL",
        "ESCAPE",
        "EXCEPT",
        "EXEC",
        "EXECUTE",
        "EXISTS",
        "EXIT",
        "FETCH",
        "FILE",
        "FILLFACTOR",
        "FOLLOWING",
        "FOR",
        "FOREIGN",
        "FREETEXT",
        "FREETEXTTABLE",
        "FROM",
        "FULL",
        "FUNCTION",
        "GOTO",
        "GRANT",
        "GROUP",
        "HAVING",
        "HOLDLOCK",
        "IDENTITY",
        "IDENTITYCOL",
        "IDENTITY_INSERT",
        "IF",
        "IN",
        "INDEX",
        "INNER",
        "INSERT",
        "INTERSECT",
        "INTO",
        "IS",
        "JOIN",
        "KEY",
        "KILL",
        "LEFT",
        "LIKE",
        "LINENO",
        "LOAD",
        "MATCH",
        "MERGE",
        "NATIONAL",
        "NOCHECK",
        "NONCLUSTERED",
        "NOT",
        "NULL",
        "NULLIF",
        "OF",
        "OFF",
        "OFFSETS",
        "ON",
        "OPEN",
        "OPENDATASOURCE",
        "OPENQUERY",
        "OPENROWSET",
        "OPENXML",
        "OPTION",
        "OR",
        "ORDER",
        "OUTER",
        "OVER",
        "PERCENT",
        "PLAN",
        "PRECEDING",
        "PRECISION",
        "PRIMARY",
        "PRINT",
        "PROC",
        "PROCEDURE",
        "PUBLIC",
        "RAISERROR",
        "READ",
        "READTEXT",
        "RECONFIGURE",
        "REFERENCES",
        "REPLICATION",
        "RESTORE",
        "RESTRICT",
        "RETURN",
        "REVOKE",
        "RIGHT",
        "ROLLBACK",
        "ROWCOUNT",
        "ROWGUIDCOL",
        "ROWS?",
        "RULE",
        "SAVE",
        "SCHEMA",
        "SELECT",
        "SESSION_USER",
        "SET",
        "SETUSER",
        "SHUTDOWN",
        "SOME",
        "STATISTICS",
        "SYSTEM_USER",
        "TABLE",
        "TEXTSIZE",
        "THEN",
        "TO",
        "TOP",
        "TRAN",
        "TRANSACTION",
        "TRIGGER",
        "TRUNCATE",
        "TSEQUAL",
        "UNBOUNDED",
        "UNION",
        "UNIQUE",
        "UPDATE",
        "UPDATETEXT",
        "USE",
        "USER",
        "USING",
        "VALUES",
        "VARYING",
        "VIEW",
        "WAITFOR",
        "WHEN",
        "WHERE",
        "WHILE",
        "WITH",
        "WRITETEXT",
        "add",
        "all",
        "alter",
        "and",
        "any",
        "apply",
        "as",
        "asc",
        "authorization",
        "backup",
        "begin",
        "between",
        "break",
        "browse",
        "bulk",
        "by",
        "cascade",
        "case",
        "check",
        "checkpoint",
        "close",
        "clustered",
        "coalesce",
        "collate",
        "column",
        "commit",
        "compute",
        "connect",
        "constraint",
        "contains",
        "containstable",
        "continue",
        "convert",
        "create",
        "cross",
        "current",
        "current_date",
        "current_time",
        "current_timestamp",
        "current_user",
        "cursor",
        "database",
        "dbcc",
        "deallocate",
        "declare",
        "default",
        "delete",
        "deny",
        "desc",
        "disk",
        "distinct",
        "distributed",
        "double",
        "drop",
        "dummy",
        "dump",
        "else",
        "end",
        "errlvl",
        "escape",
        "except",
        "exec",
        "execute",
        "exists",
        "exit",
        "fetch",
        "file",
        "fillfactor",
        "following",
        "for",
        "foreign",
        "freetext",
        "freetexttable",
        "from",
        "full",
        "function",
        "goto",
        "grant",
        "group",
        "having",
        "holdlock",
        "identity",
        "identitycol",
        "identity_insert",
        "if",
        "in",
        "index",
        "inner",
        "insert",
        "intersect",
        "into",
        "is",
        "join",
        "key",
        "kill",
        "left",
        "like",
        "lineno",
        "load",
        "match",
        "merge",
        "national",
        "nocheck",
        "nonclustered",
        "not",
        "null",
        "nullif",
        "of",
        "off",
        "offsets",
        "on",
        "open",
        "opendatasource",
        "openquery",
        "openrowset",
        "openxml",
        "option",
        "or",
        "order",
        "outer",
        "over",
        "percent",
        "plan",
        "preceding",
        "precision",
        "primary",
        "print",
        "proc",
        "procedure",
        "public",
        "raiserror",
        "read",
        "readtext",
        "reconfigure",
        "references",
        "replication",
        "restore",
        "restrict",
        "return",
        "revoke",
        "right",
        "rollback",
        "rowcount",
        "rowguidcol",
        "rows?",
        "rule",
        "save",
        "schema",
        "select",
        "session_user",
        "set",
        "setuser",
        "shutdown",
        "some",
        "statistics",
        "system_user",
        "table",
        "textsize",
        "then",
        "to",
        "top",
        "tran",
        "transaction",
        "trigger",
        "truncate",
        "tsequal",
        "unbounded",
        "union",
        "unique",
        "update",
        "updatetext",
        "use",
        "user",
        "using",
        "values",
        "varying",
        "view",
        "waitfor",
        "when",
        "where",
        "while",
        "with",
        "writetext"
    ]

    static let kotlin = [
        "package",
        "import",
        "typealias",
        "class",
        "interface",
        "constructor",
        "by",
        "where",
        "init",
        "companion",
        "object",
        "val",
        "var",
        "fun",
        "this",
        "dynamic",
        "if",
        "try",
        "catch",
        "finally",
        "do",
        "while",
        "true",
        "false",
        "in",
        "!in",
        "as",
        "!as",
        "is",
        "!is",
        "throw",
        "return",
        "continue",
        "break",
        "else",
        "abstract",
        "final",
        "enum",
        "open",
        "annatation",
        "sealed",
        "data",
        "override",
        "lateinit",
        "private",
        "protected",
        "public",
        "internal",
        "in",
        "out",
        "inline",
        "noinline",
        "crossinline",
        "vararg",
        "const",
        "suspend",
        "reified",
        "null"
    ]

    static let js = [
        "abstract",
        "arguments",
        "await",
        "boolean",
        "break",
        "byte",
        "case",
        "catch",
        "char",
        "class",
        "const",
        "continue",
        "debugger",
        "default",
        "delete",
        "do",
        "double",
        "else",
        "enum",
        "eval",
        "export",
        "extends",
        "false",
        "final",
        "finally",
        "float",
        "for",
        "function",
        "goto",
        "if",
        "implements",
        "import",
        "in",
        "instanceof",
        "int",
        "interface",
        "let",
        "long",
        "native",
        "new",
        "null",
        "package",
        "private",
        "protected",
        "public",
        "return",
        "short",
        "static",
        "super",
        "switch",
        "synchronized",
        "this",
        "throw",
        "throws",
        "transient",
        "true",
        "try",
        "typeof",
        "var",
        "void",
        "volatile",
        "while",
        "with",
        "yield"
    ]

    static let r = [
        "if",
        "else",
        "repeat",
        "while",
        "function",
        "for",
        "in",
        "next",
        "break",
        "TRUE",
        "FALSE",
        "NULL",
        "Inf",
        "NaN",
        "NA",
        "NA_integer_",
        "NA_real_",
        "NA_complex_",
        "NA_character_"
    ]

    static let haskell = [
        "case",
        "class",
        "data",
        "default",
        "deriving",
        "do",
        "else",
        "forall",
        "if",
        "import",
        "in",
        "infix",
        "infixl",
        "infixr",
        "instance",
        "let",
        "module",
        "newtype",
        "of",
        "qualified",
        "then",
        "type",
        "where",
        "_",
        "foreign",
        "ccall",
        "as",
        "safe",
        "unsafe"
    ]
}
