//
//  Section+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Section {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedBeginDate: Date?
    @NSManaged var managedSoftDeadline: Date?
    @NSManaged var managedHardDeadline: Date?
    @NSManaged var managedActive: NSNumber?
    @NSManaged var managedProgressId : String?
    @NSManaged var managedTestSectionAction: String?
    @NSManaged var managedIsExam: NSNumber?
    
    @NSManaged var managedUnitsArray : NSObject?

    @NSManaged var managedUnits : NSOrderedSet?
    @NSManaged var managedCourse : Course?
    @NSManaged var managedProgress : Progress?
    
    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Section", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Section.oldEntity, insertInto: CoreDataHelper.instance.context)
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
    
    var testSectionAction : String? {
        get {
            return managedTestSectionAction
        }
        set(value) {
            managedTestSectionAction = value
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

    var title : String {
        set(value){
            self.managedTitle = value
        }
        get {
            return managedTitle ?? "No title"
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
    
    var isExam : Bool {
        set(value){
            self.managedIsExam = value as NSNumber?
        }
        get {
            return managedIsExam?.boolValue ?? false
        }
    }
    
    var course : Course? {
        return managedCourse
    }
    
    var progress : Progress? {
        get {
            return managedProgress
        }
        set(value) {
            managedProgress = value
        }
    }
    
    var units : [Unit] {
        get {
            return (managedUnits?.array as? [Unit]) ?? []
        }
        set(value) {
            managedUnits = NSOrderedSet(array: value)
        }
    }
    
    
    var unitsArray: [Int] {
        set(value){
            self.managedUnitsArray = value as NSObject?
        }
        get {
            return (self.managedUnitsArray as? [Int]) ?? []
        }
    }
    
}
