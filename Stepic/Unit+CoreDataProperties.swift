//
//  Unit+CoreDataProperties.swift
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

extension Unit {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedBeginDate: NSDate?
    @NSManaged var managedSoftDeadline: NSDate?
    @NSManaged var managedHardDeadline: NSDate?
    @NSManaged var managedActive: NSNumber?
    @NSManaged var managedLessonId: NSNumber?
    @NSManaged var managedProgressId : String?
    
    @NSManaged var managedAssignmentsArray : NSObject?

    
    @NSManaged var managedSection: Section?
    @NSManaged var managedLesson: Lesson?
    @NSManaged var managedProgress: Progress?
    
    @NSManaged var managedAssignments : NSOrderedSet?
    
    
    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Unit", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Unit.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId?.integerValue ?? -1
        }
    }
    
    var progressId : String? {
        get {
            return managedProgressId
        }
        set(value) {
            managedProgressId = value
        }
    }
    
    var lessonId : Int {
        set(newId){
            self.managedLessonId = newId
        }
        get {
            return managedLessonId?.integerValue ?? -1
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

    
    var beginDate : NSDate? {
        set(date){
            self.managedBeginDate = date
        }
        get {
            return managedBeginDate
        }
    }
    
    var softDeadline: NSDate? {
        set(date){ 
            self.managedSoftDeadline = date
        }
        get{
            return managedSoftDeadline
        }
    }
    
    var hardDeadline: NSDate? {
        set(date){ 
            self.managedHardDeadline = date
        }
        get{
            return managedHardDeadline
        }
    }
    
    var isActive : Bool {
        set(value){
            self.managedActive = value
        }
        get {
            return managedActive?.boolValue ?? false
        }
    }
    
    var section : Section {
        return managedSection!
    }
    
    var progress : Progress? {
        get {
            return managedProgress
        }
        set(value) {
            managedProgress = value
        }
    }
    
    var lesson : Lesson? {
        get {
            return managedLesson
        }
        set(value) {
            self.managedLesson = value
        }
    }
    
    var assignmentsArray : [Int] {
        set(value){
            self.managedAssignmentsArray = value
        }
        
        get {
            return (self.managedAssignmentsArray as? [Int]) ?? []
        }
        
    }
    
    var assignments : [Assignment] {
        get {
            return (managedAssignments?.array as? [Assignment]) ?? []
        }
        
        set(value) {
            managedAssignments = NSOrderedSet(array: value)
        }
    }
    
}
