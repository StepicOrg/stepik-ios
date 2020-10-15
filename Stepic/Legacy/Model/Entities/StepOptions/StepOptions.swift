//
//  StepOptions.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class StepOptions: NSManagedObject {
    var languages: [CodeLanguage] {
        self.limits.compactMap { $0.language }
    }

    override var description: String {
        "StepOptions(limits: \(self.limits), templates: \(self.templates), samples: \(self.samples)"
    }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.executionTimeLimit = json[JSONKey.executionTimeLimit.rawValue].doubleValue
        self.executionMemoryLimit = json[JSONKey.executionMemoryLimit.rawValue].doubleValue
        self.isRunUserCodeAllowed = json[JSONKey.isRunUserCodeAllowed.rawValue].boolValue

        guard let templatesJSON = json[JSONKey.codeTemplates.rawValue].dictionary,
              let limitsJSON = json[JSONKey.limits.rawValue].dictionary else {
            return
        }

        for (key, value) in templatesJSON {
            if let templateString = value.string {
                if let template = self.template(language: key, isUserGenerated: false) {
                    template.update(language: key, template: templateString)
                } else {
                    self.templates += [CodeTemplate(language: key, template: templateString, isUserGenerated: false)]
                }
            }
        }

        for (key, value) in limitsJSON {
            if let limit = self.limit(language: key) {
                limit.update(language: key, json: value)
            } else {
                self.limits += [CodeLimit(language: key, json: value)]
            }
        }

        let oldSamples = self.samples
        oldSamples.forEach { CoreDataHelper.shared.deleteFromStore($0) }
        self.samples = []

        if let samplesArray = json[JSONKey.samples.rawValue].array {
            for sampleJSON in samplesArray {
                if let sampleArray = sampleJSON.arrayObject as? [String] {
                    self.samples += [
                        CodeSample(
                            input: sampleArray[0].replacingOccurrences(of: "\n", with: "<br>"),
                            output: sampleArray[1].replacingOccurrences(of: "\n", with: "<br>")
                        )
                    ]
                }
            }
        }
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? StepOptions else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.executionTimeLimit != object.executionTimeLimit { return false }
        if self.executionMemoryLimit != object.executionMemoryLimit { return false }
        if self.isRunUserCodeAllowed != object.isRunUserCodeAllowed { return false }

        if self.limits.count != object.limits.count { return false }
        for (lhsLimit, rhsLimit) in zip(self.limits, object.limits) {
            if !lhsLimit.equals(rhsLimit) {
                return false
            }
        }

        if self.templates.count != object.templates.count { return false }
        for (lhsTemplate, rhsTemplate) in zip(self.templates, object.templates) {
            if !lhsTemplate.equals(rhsTemplate) {
                return false
            }
        }

        if self.samples.count != object.samples.count { return false }
        for (lhsSample, rhsSample) in zip(self.samples, object.samples) {
            if !lhsSample.equals(rhsSample) {
                return false
            }
        }

        return true
    }

    func limit(language: CodeLanguage) -> CodeLimit? {
        self.limit(language: language.rawValue)
    }

    func template(language: CodeLanguage, userGenerated: Bool) -> CodeTemplate? {
        self.template(language: language.rawValue, isUserGenerated: userGenerated)
    }

    private func limit(language: String) -> CodeLimit? {
        self.limits.filter { $0.languageString == language }.first
    }

    private func template(language: String, isUserGenerated: Bool) -> CodeTemplate? {
        self.templates.filter { $0.languageString == language && $0.isUserGenerated == isUserGenerated }.first
    }

    enum JSONKey: String {
        case executionTimeLimit = "execution_time_limit"
        case executionMemoryLimit = "execution_memory_limit"
        case isRunUserCodeAllowed = "is_run_user_code_allowed"
        case codeTemplates = "code_templates"
        case limits
        case samples
    }
}
