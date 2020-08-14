//
//  Assignment+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData
import Foundation

extension Assignment {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedStepId: NSNumber?
    @NSManaged var managedUnitId: NSNumber?
    @NSManaged var managedProgressId: String?

    @NSManaged var managedUnit: Unit?
    @NSManaged var managedProgress: Progress?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Assignment", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<Assignment> {
        NSFetchRequest<Assignment>(entityName: "Assignment")
    }

    convenience init() {
        self.init(entity: Assignment.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
             managedId?.intValue ?? -1
        }
    }

    var stepId: Int {
        set(newId) {
            self.managedStepId = newId as NSNumber?
        }
        get {
             managedStepId?.intValue ?? -1
        }
    }

    var unitId: Int {
        set(newId) {
            self.managedUnitId = newId as NSNumber?
        }
        get {
             managedUnitId?.intValue ?? -1
        }
    }

    var progressId: String {
        get {
            self.managedProgressId ?? ""
        }
        set {
            self.managedProgressId = newValue
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

    var progress: Progress? {
        get {
            self.managedProgress
        }
        set {
            self.managedProgress = newValue
        }
    }
}
