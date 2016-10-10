//
//  User+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedProfile: NSNumber?
    @NSManaged var managedPrivate: NSNumber?
    @NSManaged var managedBio: String?
    @NSManaged var managedDetails: String?
    @NSManaged var managedFirstName: String?
    @NSManaged var managedLastName: String?
    @NSManaged var managedAvatarURL: String?
    @NSManaged var managedLevel: NSNumber?

    @NSManaged var managedInstructedCourses : NSSet?

    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "User", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: User.oldEntity, insertInto: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(value) {
            managedId = value as NSNumber?
        }
        get {
            return managedId?.intValue ?? 0
        }
    }
    
    var profile : Int {
        set(value){
            managedProfile = value as NSNumber?
        }
        get {
            return managedProfile?.intValue ?? 0
        }
    }
    
    var isPrivate : Bool {
        set(value){
            managedPrivate = value as NSNumber?
        }
        get {
            return managedPrivate?.boolValue ?? true
        }
    }
    
    var bio : String {
        set(value){
            managedBio = value
        }
        get {
            return managedBio ?? "No bio"
        }
    }
    
    var details : String {
        set(value){
            managedDetails = value
        }
        get {
            return managedDetails ?? "No details"
        }
    }
    
    var firstName : String {
        set(value){
            managedFirstName = value
        }
        get {
            return managedFirstName ?? "No first name"
        }
    }
    
    var lastName : String {
        set(value){
            managedLastName = value
        }
        get {
            return managedLastName ?? "No last name"
        }
    }
    
    var avatarURL : String {
        set(value){
            managedAvatarURL = value
        }
        get {
            return managedAvatarURL ?? "http://www.yoprogramo.com/wp-content/uploads/2015/08/human-error-in-finance-640x324.jpg"
        }
    }
    
    var level : Int {
        set(value){
            managedLevel = value as NSNumber?
        }
        get {
            return managedLevel?.intValue ?? 0
        }
    }
    
    var instructedCourses : [Course] {
        get {
            return managedInstructedCourses?.allObjects as! [Course]
        }
    }
    
    func addInstructedCourse(_ course : Course) {
        var mutableItems = managedInstructedCourses?.allObjects as! [Course]
        mutableItems += [course]
        managedInstructedCourses = NSSet(array: mutableItems)
    }

}
