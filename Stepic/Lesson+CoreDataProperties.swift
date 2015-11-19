//
//  Lesson+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Lesson {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedFeatured: NSNumber?
    @NSManaged var managedPublic: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedSlug: String?

    @NSManaged var managedStepsArray : NSObject?

    @NSManaged var managedSteps : NSOrderedSet?
    
    @NSManaged var managedUnit : Unit?
//    @NSManaged var managedIsCached : NSNumber?
    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Lesson", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Lesson.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId?.integerValue ?? -1
        }
    }
    
//    var isCached : Bool {
//        set(value){
//            self.managedIsCached = value
//            CoreDataHelper.instance.save()
//        }
//        get {
//            return managedIsCached?.boolValue ?? false
//        }
//    }
    
    var title : String {
        set(value){
            self.managedTitle = value
        }
        get {
            return managedTitle ?? "No title"
        }
    }
    
    var slug : String {
        set(value){
            self.managedSlug = value
        }
        get {
            return managedSlug ?? ""
        }
    }
    
    var isFeatured : Bool {
        set(value){
            self.managedFeatured = value
        }
        get {
            return managedFeatured?.boolValue ?? false
        }
    }
    
    var isPublic : Bool {
        set(value){
            self.managedPublic = value
        }
        get {
            return managedPublic?.boolValue ?? false
        }
    }
    
    var stepsArray : [Int] {
        set(value){
            self.managedStepsArray = value
        }
        
        get {
            return (self.managedStepsArray as? [Int]) ?? []
        }

    }
    
    var steps : [Step] {
        get {
            return (managedSteps?.array as? [Step]) ?? []
        }
        
        set(value) {
            managedSteps = NSOrderedSet(array: value)
        }
    }
    
    var unit: Unit? {
        return managedUnit
    }
}
