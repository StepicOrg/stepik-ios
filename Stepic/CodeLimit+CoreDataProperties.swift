//
//  CodeLimit+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension CodeLimit {
    @NSManaged var managedLanguage: String?
    @NSManaged var managedMemory: NSNumber?
    @NSManaged var managedTime: NSNumber?

    @NSManaged var managedOptions: StepOptions?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "CodeLimit", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: CodeLimit.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var languageString: String {
        get {
             managedLanguage ?? ""
        }
        set(value) {
            managedLanguage = value
        }
    }

    var memory: Double {
        get {
             managedMemory?.doubleValue ?? 0.0
        }
        set(value) {
            managedMemory = value as NSNumber?
        }
    }

    var time: Double {
        get {
             managedTime?.doubleValue ?? 0.0
        }
        set(value) {
            managedTime = value as NSNumber?
        }
    }
}
