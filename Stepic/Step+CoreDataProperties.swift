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
    @NSManaged var managedProgressId: String?
    @NSManaged var managedLessonId : NSNumber?
    
    @NSManaged var managedBlock: Block?
    @NSManaged var managedLesson: Lesson?
    @NSManaged var managedProgress: Progress?
    
    @NSManaged var managedDiscussionProxy: String?
    @NSManaged var managedDiscussionsCount: NSNumber?
    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Step", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Step.entity, insertInto: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
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
    
    var progressId: String? {
        get {
            return managedProgressId
        }
        set(value) {
            managedProgressId = value
        }
    }
    
    var progress : Progress? {
        get {
            return managedProgress
        }
        set(value) {
            managedProgress = value
        }
    }
    
    var discussionProxyId: String? {
        get {
            return managedDiscussionProxy
        }
        set(value) {
            managedDiscussionProxy = value
        }
    }
    
    var discussionsCount : Int? {
        get {
            return managedDiscussionsCount?.intValue
        }
        set(value) {
            managedDiscussionsCount = value as NSNumber?
        }
    }
    
    var lesson : Lesson? {
        get {
            return managedLesson
        }
        set(value) {
            managedLesson = value
        }
    }
    
}
