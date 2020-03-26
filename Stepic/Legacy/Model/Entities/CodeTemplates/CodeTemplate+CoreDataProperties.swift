//
//  CodeTemplate+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension CodeTemplate {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedTemplateString: String?
    @NSManaged var managedIsUserGenerated: NSNumber?

    @NSManaged var managedOptions: StepOptions?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "CodeTemplate", in: CoreDataHelper.shared.context)!
    }

    convenience init() {
        self.init(entity: CodeTemplate.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var languageString: String {
        get {
             managedLanguage ?? ""
        }
        set(value) {
            managedLanguage = value
        }
    }

    var templateString: String {
        get {
             managedTemplateString ?? ""
        }
        set(value) {
            managedTemplateString = value
        }
    }

    var isUserGenerated: Bool {
        get {
             managedIsUserGenerated?.boolValue ?? true
        }
        set(value) {
            managedIsUserGenerated = value as NSNumber?
        }
    }
}
