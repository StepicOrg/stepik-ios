//
//  CodeLimit.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CodeLimit: NSManagedObject {

    var language: CodeLanguage {
        return CodeLanguage(rawValue: languageString) ?? CodeLanguage.unsupported
    }

    convenience required init(language: String, json: JSON) {
        self.init()
        initialize(language: language, json: json)
    }

    func initialize(language: String, json: JSON) {
        languageString = language
        time = json["time"].doubleValue
        memory = json["memory"].doubleValue
    }

    func update(language: String, json: JSON) {
        initialize(language: language, json: json)
    }
}
