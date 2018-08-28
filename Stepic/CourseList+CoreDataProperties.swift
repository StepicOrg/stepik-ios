//
//  CourseList+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension CourseListModel {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedDescription: String?
    @NSManaged var managedLanguage: String?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedCoursesArray: NSObject?

    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "CourseList", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: CourseListModel.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
        }
    }

    var title: String {
        set(value) {
            managedTitle = value
        }
        get {
            return managedTitle ?? ""
        }
    }

    var listDescription: String {
        set(value) {
            managedDescription = value
        }
        get {
            return managedDescription ?? ""
        }
    }

    var languageString: String {
        set(value) {
            managedLanguage = value
        }
        get {
            return managedLanguage ?? ""
        }
    }

    var position: Int {
        set(value) {
            self.managedPosition = value as NSNumber?
        }
        get {
            return managedPosition?.intValue ?? 0
        }
    }

    var coursesArray: [Int] {
        set(value) {
            self.managedCoursesArray = value as NSObject?
        }
        get {
            return (self.managedCoursesArray as? [Int]) ?? []
        }
    }
}
