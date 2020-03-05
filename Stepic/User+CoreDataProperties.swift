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

import CoreData
import Foundation

extension User {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedProfile: NSNumber?
    @NSManaged var managedPrivate: NSNumber?
    @NSManaged var managedOrganization: NSNumber?
    @NSManaged var managedBio: String?
    @NSManaged var managedDetails: String?
    @NSManaged var managedFirstName: String?
    @NSManaged var managedLastName: String?
    @NSManaged var managedAvatarURL: String?
    @NSManaged var managedLevel: NSNumber?
    @NSManaged var managedJoinDate: Date?

    @NSManaged var managedInstructedCourses: NSSet?
    @NSManaged var managedAuthoredCourses: NSSet?
    @NSManaged var managedAttempts: NSSet?

    @NSManaged var managedProfileEntity: Profile?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "User", in: CoreDataHelper.shared.context)!
    }

    convenience init() {
        self.init(entity: User.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        set(value) {
            managedId = value as NSNumber?
        }
        get {
             managedId?.intValue ?? 0
        }
    }

    var profile: Int {
        set(value) {
            managedProfile = value as NSNumber?
        }
        get {
             managedProfile?.intValue ?? 0
        }
    }

    var joinDate: Date? {
        set(value) {
            managedJoinDate = value
        }
        get {
             managedJoinDate
        }
    }

    var isPrivate: Bool {
        set(value) {
            managedPrivate = value as NSNumber?
        }
        get {
             managedPrivate?.boolValue ?? true
        }
    }

    var isOrganization: Bool {
        get {
             self.managedOrganization?.boolValue ?? false
        }
        set {
            self.managedOrganization = newValue as NSNumber?
        }
    }

    var bio: String {
        set(value) {
            managedBio = value
        }
        get {
             managedBio ?? "No bio"
        }
    }

    var details: String {
        set(value) {
            managedDetails = value
        }
        get {
             managedDetails ?? "No details"
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

    var fullName: String {
        "\(self.firstName) \(self.lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var avatarURL: String {
        set(value) {
            managedAvatarURL = value
        }
        get {
             managedAvatarURL ?? "http://www.yoprogramo.com/wp-content/uploads/2015/08/human-error-in-finance-640x324.jpg"
        }
    }

    var level: Int {
        set(value) {
            managedLevel = value as NSNumber?
        }
        get {
             managedLevel?.intValue ?? 0
        }
    }

    var attempts: [AttemptEntity] {
        get {
            self.managedAttempts?.allObjects as! [AttemptEntity]
        }
        set {
            self.managedAttempts = NSSet(array: newValue)
        }
    }

    var instructedCourses: [Course] {
        get {
             managedInstructedCourses?.allObjects as! [Course]
        }
    }

    var profileEntity: Profile? {
        get {
             managedProfileEntity
        }
        set(value) {
            managedProfileEntity = value
        }
    }

    var authoredCourses: [Course] {
        get {
             self.managedAuthoredCourses?.allObjects as! [Course]
        }
    }

    func addInstructedCourse(_ course: Course) {
        var mutableItems = managedInstructedCourses?.allObjects as! [Course]
        mutableItems += [course]
        managedInstructedCourses = NSSet(array: mutableItems)
    }

    func addAuthoredCourse(_ course: Course) {
        var mutableItems = self.managedAuthoredCourses?.allObjects as! [Course]
        mutableItems += [course]
        self.managedAuthoredCourses = NSSet(array: mutableItems)
    }
}
