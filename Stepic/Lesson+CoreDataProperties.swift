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

import CoreData
import Foundation

extension Lesson {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedFeatured: NSNumber?
    @NSManaged var managedPublic: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedSlug: String?
    @NSManaged var managedCoverURL: String?
    @NSManaged var managedTimeToComplete: NSNumber?
    @NSManaged var managedVoteDelta: NSNumber?
    @NSManaged var managedPassedBy: NSNumber?
    @NSManaged var managedCanEdit: NSNumber?

    @NSManaged var managedStepsArray: NSObject?
    @NSManaged var managedSteps: NSOrderedSet?
    @NSManaged var managedUnit: Unit?

    static var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Lesson", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: Lesson.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var id: Int {
        get {
            return self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = newValue as NSNumber?
        }
    }

    var title: String {
        get {
            return self.managedTitle ?? "No title"
        }
        set {
            self.managedTitle = newValue
        }
    }

    var slug: String {
        get {
            return self.managedSlug ?? ""
        }
        set {
            self.managedSlug = newValue
        }
    }

    var coverURL: String? {
        get {
            return self.managedCoverURL
        }
        set {
            self.managedCoverURL = newValue
        }
    }

    var isFeatured: Bool {
        get {
            return self.managedFeatured?.boolValue ?? false
        }
        set {
            self.managedFeatured = newValue as NSNumber?
        }
    }

    var isPublic: Bool {
        get {
            return self.managedPublic?.boolValue ?? false
        }
        set {
            self.managedPublic = newValue as NSNumber?
        }
    }

    var canEdit: Bool {
        get {
            return self.managedCanEdit?.boolValue ?? false
        }
        set {
            self.managedCanEdit = newValue as NSNumber?
        }
    }

    var stepsArray: [IdType] {
        get {
            return (self.managedStepsArray as? [IdType]) ?? []
        }
        set {
            self.managedStepsArray = newValue as NSObject?
        }
    }

    var steps: [Step] {
        get {
            return (self.managedSteps?.array as? [Step]) ?? []
        }
        set {
            self.managedSteps = NSOrderedSet(array: newValue)
        }
    }

    var timeToComplete: Double {
        get {
            return self.managedTimeToComplete?.doubleValue ?? 0
        }
        set {
            self.managedTimeToComplete = newValue as NSNumber?
        }
    }

    var voteDelta: Int {
        get {
            return self.managedVoteDelta?.intValue ?? 0
        }
        set {
            self.managedVoteDelta = newValue as NSNumber?
        }
    }

    var passedBy: Int {
        get {
            return managedPassedBy?.intValue ?? 0
        }
        set {
            self.managedPassedBy = newValue as NSNumber?
        }
    }

    var unit: Unit? {
        return self.managedUnit
    }
}
