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
