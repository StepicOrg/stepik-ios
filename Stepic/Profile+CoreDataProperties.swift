//
//  Profile+CoreDataProperties.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension Profile {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedFirstName: String?
    @NSManaged var managedLastName: String?
    @NSManaged var managedShortBio: String?
    @NSManaged var managedDetails: String?
    @NSManaged var managedSubscribedForMail: NSNumber?
    @NSManaged var managedIsStaff: NSNumber?

    @NSManaged var managedEmailAddressesArray: NSObject?
    @NSManaged var managedEmailAddresses: NSOrderedSet?

    @NSManaged var managedUser: User?

    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Profile", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: Profile.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
        }
    }

    var firstName: String {
        set(value) {
            managedFirstName = value
        }
        get {
            return managedFirstName ?? "No first name"
        }
    }

    var lastName: String {
        set(value) {
            managedLastName = value
        }
        get {
            return managedLastName ?? "No last name"
        }
    }

    var shortBio: String {
        set {
            managedShortBio = newValue
        }
        get {
            return managedShortBio ?? ""
        }
    }

    var details: String {
        set {
            managedDetails = newValue
        }
        get {
            return managedDetails ?? ""
        }
    }

    var subscribedForMail: Bool {
        set(value) {
            managedSubscribedForMail = value as NSNumber?
        }
        get {
            return managedSubscribedForMail?.boolValue ?? true
        }
    }

    var isStaff: Bool {
        set(value) {
            managedIsStaff = value as NSNumber?
        }
        get {
            return managedIsStaff?.boolValue ?? false
        }
    }

    var emailAddressesArray: [Int] {
        get {
            return (self.managedEmailAddressesArray as? [Int]) ?? []
        }
        set {
            self.managedEmailAddressesArray = newValue as NSObject?
        }
    }

    var emailAddresses: [EmailAddress] {
        get {
            return (self.managedEmailAddresses?.array as? [EmailAddress]) ?? []
        }
        set {
            self.managedEmailAddresses = NSOrderedSet(array: newValue)
        }
    }

    var user: User? {
        get {
            return managedUser
        }
        set(value) {
            managedUser = value
        }
    }
}
