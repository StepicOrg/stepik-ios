//
//  Progress+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Progress {

    @NSManaged var managedId: String?
    @NSManaged var managedIsPassed: NSNumber?
    @NSManaged var managedScore: NSNumber?
    @NSManaged var managedNumberOfSteps: NSNumber?
    @NSManaged var managedNumberOfStepsPassed: NSNumber?
    @NSManaged var managedCost: NSNumber?

    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Progress", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Progress.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : String {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId ?? ""
        }
    }
    
    var isPassed : Bool {
        get {
            return managedIsPassed?.boolValue ?? false
        }
        set(value) {
            managedIsPassed = value
        }
    }
    
    var score : Int {
        get {
            return managedScore?.integerValue ?? 0
        }
        set(value) {
            managedScore = value
        }
    }
    
    var numberOfSteps : Int {
        get {
            return managedNumberOfSteps?.integerValue ?? 0
        }
        set(value) {
            managedNumberOfSteps = value
        }
    }
    
    var numberOfStepsPassed : Int {
        get {
            return managedNumberOfStepsPassed?.integerValue ?? 0
        }
        set(value) {
            managedNumberOfStepsPassed = value
        }
    }
    
    var cost : Int {
        get {
            return managedCost?.integerValue ?? 0
        }
        set(value) {
            managedCost = value
        }
    }
}
