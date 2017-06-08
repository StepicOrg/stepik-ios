//
//  StepOptions.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class StepOptions: NSManagedObject {
    
    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        guard let templatesJSON = json["code_templates"].dictionary,
            let limitsJSON = json["limits"].dictionary else {
                return
        }
        for (key, value) in templatesJSON {
            if let templateString = value.string {
                if let template = template(language: key, userGenerated: false) {
                    template.update(language: key, template: templateString)
                } else {
                    templates += [CodeTemplate(language: key, template: templateString)]
                }
            }
        }
        
        for (key, value) in limitsJSON {
            if let limit = limit(language: key) {
                limit.update(language: key, json: value)
            } else {
                limits += [CodeLimit(language: key, json: value)]
            }
        }
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
    func limit(language: String) -> CodeLimit? {
        return limits.lazy.filter({
            $0.languageString == language
        }).first
    }
    
    var languages : [String] {
        return limits.flatMap({
            return $0.languageString
        })
    }
    
    func template(language: String, userGenerated: Bool) -> CodeTemplate? {
        return templates.lazy.filter({
            $0.languageString == language && $0.isUserGenerated == userGenerated
        }).first
    }
}
