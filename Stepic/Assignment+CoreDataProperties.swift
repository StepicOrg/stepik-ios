//
//  Assignment+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Assignment {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedStepId: NSNumber?
    @NSManaged var managedUnitId: NSNumber?

    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Assignment", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Assignment.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId?.integerValue ?? -1
        }
    }
    
    var stepId : Int {
        set(newId){
            self.managedStepId = newId
        }
        get {
            return managedStepId?.integerValue ?? -1
        }
    }
    
    var unitId : Int {
        set(newId){
            self.managedUnitId = newId
        }
        get {
            return managedUnitId?.integerValue ?? -1
        }
    }
    
}
