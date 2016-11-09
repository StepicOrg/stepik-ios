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

    
    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Assignment", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Assignment.oldEntity, insertInto: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
        }
    }
    
    var stepId : Int {
        set(newId){
            self.managedStepId = newId as NSNumber?
        }
        get {
            return managedStepId?.intValue ?? -1
        }
    }
    
    var unitId : Int {
        set(newId){
            self.managedUnitId = newId as NSNumber?
        }
        get {
            return managedUnitId?.intValue ?? -1
        }
    }
    
}
