//
//  StepOptions+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension StepOptions {
    @NSManaged var managedExecutionTimeLimit: NSNumber?
    @NSManaged var managedExecutionMemoryLimit: NSNumber?
    
    @NSManaged var managedLimits: NSOrderedSet?
    @NSManaged var managedTemplates: NSOrderedSet?
    @NSManaged var managedSamples: NSOrderedSet?

    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "StepOptions", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: StepOptions.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var executionTimeLimit: Double {
        get {
            return self.managedExecutionTimeLimit?.doubleValue ?? 0.0
        }
        set {
            self.managedExecutionTimeLimit = newValue as NSNumber?
        }
    }

    var executionMemoryLimit: Double {
        get {
            return self.managedExecutionMemoryLimit?.doubleValue ?? 0.0
        }
        set {
            self.managedExecutionMemoryLimit = newValue as NSNumber?
        }
    }
    
    var limits: [CodeLimit] {
        get {
            return (managedLimits?.array as? [CodeLimit]) ?? []
        }
        set(value) {
            managedLimits = NSOrderedSet(array: value)
        }
    }

    var templates: [CodeTemplate] {
        get {
            return (managedTemplates?.array as? [CodeTemplate]) ?? []
        }
        set(value) {
            managedTemplates = NSOrderedSet(array: value)
        }
    }

    var samples: [CodeSample] {
        get {
            return (managedSamples?.array as? [CodeSample]) ?? []
        }
        set(value) {
            managedSamples = NSOrderedSet(array: value)
        }
    }
}
