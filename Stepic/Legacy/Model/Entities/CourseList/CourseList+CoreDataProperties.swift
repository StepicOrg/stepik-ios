//
//  CourseList+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension CourseListModel {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedTitle: String?
    @NSManaged var managedDescription: String?
    @NSManaged var managedLanguage: String?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedCoursesArray: NSObject?
    @NSManaged var managedSimilarAuthorsArray: NSObject?
    @NSManaged var managedSimilarCourseListsArray: NSObject?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "CourseList", in: CoreDataHelper.shared.context)!
    }

    convenience init() {
        self.init(entity: CourseListModel.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
             managedId?.intValue ?? -1
        }
    }

    var title: String {
        set(value) {
            managedTitle = value
        }
        get {
             managedTitle ?? ""
        }
    }

    var listDescription: String {
        set(value) {
            managedDescription = value
        }
        get {
             managedDescription ?? ""
        }
    }

    var languageString: String {
        set(value) {
            managedLanguage = value
        }
        get {
             managedLanguage ?? ""
        }
    }

    var position: Int {
        set(value) {
            self.managedPosition = value as NSNumber?
        }
        get {
             managedPosition?.intValue ?? 0
        }
    }

    var coursesArray: [Int] {
        set(value) {
            self.managedCoursesArray = value as NSObject?
        }
        get {
             (self.managedCoursesArray as? [Int]) ?? []
        }
    }

    var similarAuthorsArray: [Int] {
        get {
            self.managedSimilarAuthorsArray as? [Int] ?? []
        }
        set {
            self.managedSimilarAuthorsArray = NSArray(array: newValue)
        }
    }

    var similarCourseListsArray: [Int] {
        get {
            self.managedSimilarCourseListsArray as? [Int] ?? []
        }
        set {
            self.managedSimilarCourseListsArray = NSArray(array: newValue)
        }
    }
}
