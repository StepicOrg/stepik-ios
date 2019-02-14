//
//  CourseReview+CoreDataProperties.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension CourseReview {
    @NSManaged var managedText: String?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedScore: NSNumber?
    @NSManaged var managedCreateDate: Date?

    @NSManaged var managedCourse: Course?

    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "CourseReview", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: CourseReview.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var id: Int {
        set {
            self.managedId = newValue as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
        }
    }

    var score: Int {
        get {
            return managedScore?.intValue ?? 0
        }
        set {
            managedScore = newValue as NSNumber?
        }
    }

    var userID: User.IdType {
        get {
            return managedUserId?.intValue ?? 0
        }
        set {
            managedUserId = newValue as NSNumber?
        }
    }

    var courseID: Course.IdType {
        get {
            return managedCourseId?.intValue ?? 0
        }
        set {
            managedCourseId = newValue as NSNumber?
        }
    }

    var course: Course? {
        get {
            return managedCourse
        }
        set {
            managedCourse = newValue
        }
    }

    var creationDate: Date {
        get {
            return managedCreateDate ?? Date()
        }
        set {
            managedCreateDate = newValue
        }
    }

    var text: String {
        get {
            return managedText ?? ""
        }
        set {
            managedText = newValue
        }
    }
}
