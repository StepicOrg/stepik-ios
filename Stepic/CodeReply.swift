//
//  CodeReply.swift
//  Stepic
//
//  Created by Ostrenkiy on 09.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class CodeReply: Reply {
    var code: String
    var language: CodeLanguage?
    var languageName: String

    var description: String {
        return "CodeReply(code: \(self.code), languageName: \(self.languageName))"
    }

    init(code: String, languageName: String) {
        self.code = code
        self.language = CodeLanguage(rawValue: languageName)
        self.languageName = languageName
    }

    init(code: String, language: CodeLanguage) {
        self.code = code
        self.language = language
        self.languageName = language.rawValue
    }

    required init(json: JSON) {
        code = json["code"].stringValue
        languageName = json["language"].stringValue
        language = CodeLanguage(rawValue: languageName)
    }

    var dictValue: [String: Any] {
        return ["code": code, "language": languageName]
    }
}
