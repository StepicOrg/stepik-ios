//
//  Step+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Step {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedStatus: String?
    
    @NSManaged var managedBlock: Block?
    @NSManaged var managedLesson: Lesson?
        
    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Step", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Step.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId?.integerValue ?? -1
        }
    }
    
    var position : Int {
        set(value){
            self.managedPosition = value
        }
        get {
            return managedPosition?.integerValue ?? -1
        }
    }
    
    var status : String {
        set(value){
            self.managedStatus = value
        }
        get {
            return managedStatus ?? "no status"
        }
    }
    
    var block : Block {
        get {
            return managedBlock!
        }
        
        set(value) {
            managedBlock = value
        }
    }
    
}
