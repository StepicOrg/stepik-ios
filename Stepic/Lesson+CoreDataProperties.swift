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
    @NSManaged var managedCoverURL: String?
    
    @NSManaged var managedStepsArray : NSObject?

    @NSManaged var managedSteps : NSOrderedSet?
    
    @NSManaged var managedUnit : Unit?
//    @NSManaged var managedIsCached : NSNumber?
    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Lesson", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Lesson.entity, insertInto: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
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
    
    var coverURL : String? {
        set(value) {
            managedCoverURL = value
        }
        get {
            return managedCoverURL
        }
    }
    
    var isFeatured : Bool {
        set(value){
            self.managedFeatured = value as NSNumber?
        }
        get {
            return managedFeatured?.boolValue ?? false
        }
    }
    
    var isPublic : Bool {
        set(value){
            self.managedPublic = value as NSNumber?
        }
        get {
            return managedPublic?.boolValue ?? false
        }
    }
    
    var stepsArray : [Int] {
        set(value){
            self.managedStepsArray = value as NSObject?
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
