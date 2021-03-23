//
//  CourseReviewSummary+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension CourseReviewSummary {
    @NSManaged var managedDistribution: NSObject?
    @NSManaged var managedAverage: NSNumber?
    @NSManaged var managedCount: NSNumber?
    @NSManaged var managedId: NSNumber?

    @NSManaged var managedCourse: Course?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "CourseReviewSummary", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<CourseReviewSummary> {
        NSFetchRequest<CourseReviewSummary>(entityName: "CourseReviewSummary")
    }

    convenience init() {
        self.init(entity: CourseReviewSummary.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var average: Float {
        get {
            self.managedAverage?.floatValue ?? 0
        }
        set {
            self.managedAverage = NSNumber(value: newValue)
        }
    }

    var count: Int {
        get {
            self.managedCount?.intValue ?? 0
        }
        set {
            self.managedCount = NSNumber(value: newValue)
        }
    }

    var distribution: [Int] {
        get {
            self.managedDistribution as? [Int] ?? []
        }
        set {
            self.managedDistribution = NSArray(array: newValue)
        }
    }
}
