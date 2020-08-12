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
    @NSManaged var managedSubscribedForMarketing: NSNumber?
    @NSManaged var managedSubscribedForPartners: NSNumber?
    @NSManaged var managedSubscribedForNewsEn: NSNumber?
    @NSManaged var managedSubscribedForNewsRu: NSNumber?
    @NSManaged var managedIsWebPushEnabled: NSNumber?
    @NSManaged var managedIsVoteNotificationsEnabled: NSNumber?
    @NSManaged var managedIsStaff: NSNumber?

    @NSManaged var managedEmailAddressesArray: NSObject?
    @NSManaged var managedEmailAddresses: NSOrderedSet?

    @NSManaged var managedUser: User?

    @NSManaged var managedUserActivity: UserActivityEntity?

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    static var fetchRequest: NSFetchRequest<Profile> {
        NSFetchRequest<Profile>(entityName: "Profile")
    }

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Profile", in: CoreDataHelper.shared.context)!
    }

    convenience init() {
        self.init(entity: Profile.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
             managedId?.intValue ?? -1
        }
    }

    var firstName: String {
        set(value) {
            managedFirstName = value
        }
        get {
             managedFirstName ?? "No first name"
        }
    }

    var lastName: String {
        set(value) {
            managedLastName = value
        }
        get {
             managedLastName ?? "No last name"
        }
    }

    var shortBio: String {
        set {
            managedShortBio = newValue
        }
        get {
             managedShortBio ?? ""
        }
    }

    var details: String {
        set {
            managedDetails = newValue
        }
        get {
             managedDetails ?? ""
        }
    }

    var subscribedForMail: Bool {
        set(value) {
            managedSubscribedForMail = value as NSNumber?
        }
        get {
             managedSubscribedForMail?.boolValue ?? true
        }
    }

    var subscribedForMarketing: Bool {
        get {
            self.managedSubscribedForMarketing?.boolValue ?? false
        }
        set {
            self.managedSubscribedForMarketing = NSNumber(value: newValue)
        }
    }

    var subscribedForPartners: Bool {
        get {
            self.managedSubscribedForPartners?.boolValue ?? false
        }
        set {
            self.managedSubscribedForPartners = NSNumber(value: newValue)
        }
    }

    var subscribedForNewsEn: Bool {
        get {
            self.managedSubscribedForNewsEn?.boolValue ?? true
        }
        set {
            self.managedSubscribedForNewsEn = NSNumber(value: newValue)
        }
    }

    var subscribedForNewsRu: Bool {
        get {
            self.managedSubscribedForNewsRu?.boolValue ?? false
        }
        set {
            self.managedSubscribedForNewsRu = NSNumber(value: newValue)
        }
    }

    var isWebPushEnabled: Bool {
        get {
            self.managedIsWebPushEnabled?.boolValue ?? true
        }
        set {
            self.managedIsWebPushEnabled = NSNumber(value: newValue)
        }
    }

    var isVoteNotificationsEnabled: Bool {
        get {
            self.managedIsVoteNotificationsEnabled?.boolValue ?? true
        }
        set {
            self.managedIsVoteNotificationsEnabled = NSNumber(value: newValue)
        }
    }

    var isStaff: Bool {
        set(value) {
            managedIsStaff = value as NSNumber?
        }
        get {
             managedIsStaff?.boolValue ?? false
        }
    }

    var emailAddressesArray: [Int] {
        get {
             (self.managedEmailAddressesArray as? [Int]) ?? []
        }
        set {
            self.managedEmailAddressesArray = newValue as NSObject?
        }
    }

    var emailAddresses: [EmailAddress] {
        get {
             (self.managedEmailAddresses?.array as? [EmailAddress]) ?? []
        }
        set {
            self.managedEmailAddresses = NSOrderedSet(array: newValue)
        }
    }

    var user: User? {
        get {
             managedUser
        }
        set(value) {
            managedUser = value
        }
    }

    var userActivity: UserActivityEntity? {
        get {
            self.managedUserActivity
        }
        set {
            self.managedUserActivity = newValue
        }
    }
}
