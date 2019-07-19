//
//  CodeTemplate.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CodeTemplate: NSManagedObject {
    var language: CodeLanguage? {
        return CodeLanguage(rawValue: languageString)
    }

    override var description: String {
        return "CodeTemplate(languageString: \(self.languageString), templateString: \(self.templateString)"
    }

    convenience required init(language: CodeLanguage, template: String) {
        self.init()
        let lan = language.rawValue
        initialize(language: lan, template: template)
    }

    convenience required init(language: String, template: String) {
        self.init()
        initialize(language: language, template: template)
    }

    convenience required init(language: String, template: String, isUserGenerated: Bool) {
        self.init()
        initialize(language: language, template: template)
        self.isUserGenerated = isUserGenerated
    }

    func initialize(language: String, template: String) {
        languageString = language
        templateString = template
    }

    func update(language: String, template: String) {
        initialize(language: language, template: template)
    }
}
