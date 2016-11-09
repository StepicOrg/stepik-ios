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
    @NSManaged var managedBeginDate: Date?
    @NSManaged var managedSoftDeadline: Date?
    @NSManaged var managedHardDeadline: Date?
    @NSManaged var managedActive: NSNumber?
    @NSManaged var managedLessonId: NSNumber?
    @NSManaged var managedProgressId : String?
    
    @NSManaged var managedAssignmentsArray : NSObject?

    
    @NSManaged var managedSection: Section?
    @NSManaged var managedLesson: Lesson?
    @NSManaged var managedProgress: Progress?
    
    @NSManaged var managedAssignments : NSOrderedSet?
    
    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Unit", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Unit.oldEntity, insertInto: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
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
            self.managedLessonId = newId as NSNumber?
        }
        get {
            return managedLessonId?.intValue ?? -1
        }
    }
    
    var position : Int {
        set(value){
            self.managedPosition = value as NSNumber?
        }
        get {
            return managedPosition?.intValue ?? -1
        }
    }

    
    var beginDate : Date? {
        set(date){
            self.managedBeginDate = date
        }
        get {
            return managedBeginDate
        }
    }
    
    var softDeadline: Date? {
        set(date){ 
            self.managedSoftDeadline = date
        }
        get{
            return managedSoftDeadline
        }
    }
    
    var hardDeadline: Date? {
        set(date){ 
            self.managedHardDeadline = date
        }
        get{
            return managedHardDeadline
        }
    }
    
    var isActive : Bool {
        set(value){
            self.managedActive = value as NSNumber?
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
            self.managedAssignmentsArray = value as NSObject?
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
