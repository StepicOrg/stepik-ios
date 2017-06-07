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
    @NSManaged var managedSamples: NSObject?
    
    @NSManaged var managedLimits: NSOrderedSet?
    @NSManaged var managedTemplates: NSOrderedSet?
    
    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "StepOptions", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: StepOptions.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var samplesArray: [String] {
        set(value){
            self.managedSamples = value as NSObject?
        }
        get {
            return (self.managedSamples as? [String]) ?? []
        }
    }
    
    var limits : [CodeLimit] {
        get {
            return (managedLimits?.array as? [CodeLimit]) ?? []
        }
        
        set(value) {
            managedLimits = NSOrderedSet(array: value)
        }
    }
    
    var templates : [CodeTemplate] {
        get {
            return (managedTemplates?.array as? [CodeTemplate]) ?? []
        }
        
        set(value) {
            managedTemplates = NSOrderedSet(array: value)
        }
    }
}
