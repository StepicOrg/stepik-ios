//
//  LastStep+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension LastStep {
    @NSManaged var managedId: String?
    @NSManaged var managedStepId: NSNumber?
    @NSManaged var managedUnitId: NSNumber?

    @NSManaged var managedCourse: Course?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "LastStep", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<LastStep> {
        NSFetchRequest<LastStep>(entityName: "LastStep")
    }

    convenience init() {
        self.init(entity: LastStep.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: String {
        set (newId) {
            self.managedId = newId
        }
        get {
            if managedId == nil {
                print("Requested LastStep id when it is nil")
            }
            return managedId ?? "-1"
        }
    }

    var stepId: Int? {
        set(newId) {
            self.managedStepId = newId as NSNumber?
        }
        get {
             managedStepId?.intValue
        }
    }

    var unitId: Int? {
        set(newId) {
            self.managedUnitId = newId as NSNumber?
        }
        get {
             managedUnitId?.intValue
        }
    }
}
