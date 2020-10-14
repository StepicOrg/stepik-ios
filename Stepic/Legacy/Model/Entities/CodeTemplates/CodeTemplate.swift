//
//  CodeTemplate.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class CodeTemplate: NSManagedObject {
    var language: CodeLanguage? { CodeLanguage(rawValue: languageString) }

    override var description: String {
        "CodeTemplate(languageString: \(self.languageString), templateString: \(self.templateString)"
    }

    required convenience init(language: CodeLanguage, template: String) {
        self.init()
        let lan = language.rawValue
        self.initialize(language: lan, template: template)
    }

    required convenience init(language: String, template: String) {
        self.init()
        self.initialize(language: language, template: template)
    }

    required convenience init(language: String, template: String, isUserGenerated: Bool) {
        self.init()
        self.initialize(language: language, template: template)
        self.isUserGenerated = isUserGenerated
    }

    func initialize(language: String, template: String) {
        self.languageString = language
        self.templateString = template
    }

    func update(language: String, template: String) {
        self.initialize(language: language, template: template)
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? CodeTemplate else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.languageString != object.languageString { return false }
        if self.templateString != object.templateString { return false }
        if self.isUserGenerated != object.isUserGenerated { return false }

        return true
    }
}
