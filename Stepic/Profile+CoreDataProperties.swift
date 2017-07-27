//
//  Profile+CoreDataProperties.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension Profile {
    
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedFirstName: String?
    @NSManaged var managedLastName: String?
    @NSManaged var managedSubscribedForMail: NSNumber?
    
    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Profile", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Profile.oldEntity, insertInto: CoreDataHelper.instance.context)
    }
    
    var id: Int {
        set(newId){
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
        }
    }
    
    var firstName: String {
        set(value){
            managedFirstName = value
        }
        get {
            return managedFirstName ?? "No first name"
        }
    }
    
    var lastName: String {
        set(value){
            managedLastName = value
        }
        get {
            return managedLastName ?? "No last name"
        }
    }
    
    var subscribedForMail: Bool {
        set(value){
            managedSubscribedForMail = value as NSNumber?
        }
        get {
            return managedSubscribedForMail?.boolValue ?? true
        }
    }
}
