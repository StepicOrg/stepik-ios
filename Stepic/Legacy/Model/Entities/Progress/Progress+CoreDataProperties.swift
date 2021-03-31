//
//  Progress+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData
import Foundation

extension Progress {
    @NSManaged var managedId: String?
    @NSManaged var managedIsPassed: NSNumber?
    @NSManaged var managedScore: NSNumber?
    @NSManaged var managedNumberOfSteps: NSNumber?
    @NSManaged var managedNumberOfStepsPassed: NSNumber?
    @NSManaged var managedCost: NSNumber?
    @NSManaged var managedLastViewed: NSNumber?

    @NSManaged var managedAssignment: Assignment?
    @NSManaged var managedStep: Step?
    @NSManaged var managedSection: Section?
    @NSManaged var managedUnit: Unit?
    @NSManaged var managedCourse: Course?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Progress", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<Progress> {
        NSFetchRequest<Progress>(entityName: "Progress")
    }

    convenience init() {
        self.init(entity: Progress.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: String {
        set(newId) {
            self.managedId = newId
        }
        get {
            managedId ?? ""
        }
    }

    var isPassed: Bool {
        get {
            managedIsPassed?.boolValue ?? false
        }
        set(value) {
            managedIsPassed = value as NSNumber?
        }
    }

    var lastViewed: Double {
        get {
            managedLastViewed?.doubleValue ?? 0
        }
        set(value) {
            managedLastViewed = value as NSNumber?
        }
    }

    var score: Float {
        get {
            self.managedScore?.floatValue ?? 0
        }
        set {
            self.managedScore = NSNumber(value: newValue)
        }
    }

    var numberOfSteps: Int {
        get {
            managedNumberOfSteps?.intValue ?? 0
        }
        set(value) {
            managedNumberOfSteps = value as NSNumber?
        }
    }

    var numberOfStepsPassed: Int {
        get {
            managedNumberOfStepsPassed?.intValue ?? 0
        }
        set(value) {
            managedNumberOfStepsPassed = value as NSNumber?
        }
    }

    var cost: Int {
        get {
            managedCost?.intValue ?? 0
        }
        set(value) {
            managedCost = value as NSNumber?
        }
    }

    var assignment: Assignment? {
        get {
            self.managedAssignment
        }
        set {
            self.managedAssignment = newValue
        }
    }

    var step: Step? {
        get {
            self.managedStep
        }
        set {
            self.managedStep = newValue
        }
    }

    var section: Section? {
        get {
            self.managedSection
        }
        set {
            self.managedSection = newValue
        }
    }

    var unit: Unit? {
        get {
            self.managedUnit
        }
        set {
            self.managedUnit = newValue
        }
    }

    var course: Course? {
        get {
            self.managedCourse
        }
        set {
            self.managedCourse = newValue
        }
    }
}
