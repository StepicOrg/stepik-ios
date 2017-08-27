//
//  CodeReply.swift
//  Stepic
//
//  Created by Ostrenkiy on 09.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class CodeReply: Reply {

    var code: String
    var language: CodeLanguage?
    var languageName: String

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

    var dictValue: [String : Any] {
        return ["code": code, "language": languageName]
    }
}
