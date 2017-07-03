//
//  CodeTemplate+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension CodeTemplate {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedTemplateString: String?
    @NSManaged var managedIsUserGenerated: NSNumber?
    
    @NSManaged var managedOptions: StepOptions?
    
    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "CodeTemplate", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: CodeTemplate.oldEntity, insertInto: CoreDataHelper.instance.context)
    }
    
    var languageString: String {
        get {
            return managedLanguage ?? ""
        }
        set(value) {
            managedLanguage = value
        }
    }
    
    var templateString: String {
        get {
            return managedTemplateString ?? ""
        }
        set(value) {
            managedTemplateString = value
        }
    }
    
    var isUserGenerated: Bool {
        get {
            return managedIsUserGenerated?.boolValue ?? true
        }
        set(value) {
            managedIsUserGenerated = value as NSNumber?
        }
    }
}
