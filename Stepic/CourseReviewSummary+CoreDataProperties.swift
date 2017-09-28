//
//  CourseReviewSummary+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension CourseReviewSummary {
    @NSManaged var managedDistribution: NSObject?
    @NSManaged var managedAverage: NSNumber?
    @NSManaged var managedCount: NSNumber?
    @NSManaged var managedId: NSNumber?
    
    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "CourseReviewSummary", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Progress.oldEntity, insertInto: CoreDataHelper.instance.context)
    }
    
    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
        }
    }
    
    var average: Float {
        get {
            return managedAverage?.floatValue ?? 0
        }
        set(value) {
            managedAverage = value as NSNumber?
        }
    }
    
    var count: Int {
        get {
            return managedCount?.intValue ?? 0
        }
        set(value) {
            managedCount = value as NSNumber?
        }
    }
    
    var distribution: [Int] {
        set(value) {
            self.managedDistribution = value as NSObject?
        }
        get {
            return (self.managedDistribution as? [Int]) ?? []
        }
    }
}
