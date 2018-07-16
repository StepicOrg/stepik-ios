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
                    templates += [CodeTemplate(language: key, template: templateString, isUserGenerated: false)]
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

        let oldSamples = samples
        oldSamples.forEach({
            CoreDataHelper.instance.deleteFromStore($0)
        })
        samples = []
        if let samplesArray = json["samples"].array {
            for sampleJSON in samplesArray {
                if let sampleArray = sampleJSON.arrayObject as? [String] {
                    samples += [CodeSample(input: sampleArray[0].replacingOccurrences(of: "\n", with: "<br>"), output: sampleArray[1].replacingOccurrences(of: "\n", with: "<br>"))]
                }
            }
        }
    }

    func update(json: JSON) {
        initialize(json)
    }

    fileprivate func limit(language: String) -> CodeLimit? {
        return limits.filter({
            $0.languageString == language
        }).first
    }

    func limit(language: CodeLanguage) -> CodeLimit? {
        let lan = language.rawValue
        return limit(language: lan)
    }

    var languages: [CodeLanguage] {
        return limits.compactMap { $0.language }
    }

    fileprivate func template(language: String, userGenerated: Bool) -> CodeTemplate? {
        return templates.filter({
            $0.languageString == language && $0.isUserGenerated == userGenerated
        }).first
    }

    func template(language: CodeLanguage, userGenerated: Bool) -> CodeTemplate? {
        let lan = language.rawValue
        return template(language: lan, userGenerated: userGenerated)
    }
}
