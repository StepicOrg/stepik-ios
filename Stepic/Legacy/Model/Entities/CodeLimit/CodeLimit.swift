//
//  CodeLimit.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class CodeLimit: NSManagedObject {
    var language: CodeLanguage? { CodeLanguage(rawValue: languageString) }

    override var description: String {
        "CodeLimit(languageString: \(self.languageString), time: \(self.time), memory: \(self.memory)"
    }

    required convenience init(language: String, json: JSON) {
        self.init()
        self.initialize(language: language, json: json)
    }

    func initialize(language: String, json: JSON) {
        self.languageString = language
        self.time = json["time"].doubleValue
        self.memory = json["memory"].doubleValue
    }

    func update(language: String, json: JSON) {
        self.initialize(language: language, json: json)
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? CodeLimit else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.languageString != object.languageString { return false }
        if self.time != object.time { return false }
        if self.memory != object.memory { return false }

        return true
    }
}
