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
    var language: CodeLanguage

    init(code: String, language: CodeLanguage) {
        self.code = code
        self.language = language
    }

    required init(json: JSON) {
        code = json["code"].stringValue
        language = CodeLanguage(rawValue: json["language"].stringValue) ?? .unsupported
    }

    var dictValue: [String : Any] {
        return ["code": code, "language": language.rawValue]
    }
}
