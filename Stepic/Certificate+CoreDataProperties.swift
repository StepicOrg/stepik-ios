//
//  Certificate+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension Certificate {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedType: String?
    @NSManaged var managedIssueDate: Date?
    @NSManaged var managedUpdateDate: Date?
    @NSManaged var managedGrade: NSNumber?
    @NSManaged var managedURL: String?
    @NSManaged var managedisPublic: NSNumber?
    @NSManaged var managedCourse: Course?

    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Certificate", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: Certificate.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            return managedId?.intValue ?? -1
        }
    }

    var courseId: Int {
        set(newId) {
            self.managedCourseId = newId as NSNumber?
        }
        get {
            return managedCourseId?.intValue ?? -1
        }
    }

    var userId: Int {
        set(newId) {
            self.managedUserId = newId as NSNumber?
        }
        get {
            return managedUserId?.intValue ?? -1
        }
    }

    var issueDate: Date? {
        set(date) {
            self.managedIssueDate = date
        }
        get {
            return managedIssueDate
        }
    }

    var updateDate: Date? {
        set(date) {
            self.managedUpdateDate = date
        }
        get {
            return managedUpdateDate
        }
    }

    enum CertificateType: String {
        case distinction = "distinction", regular = "regular"
    }

    var type: CertificateType {
        set(type) {
            self.managedType = type.rawValue
        }
        get {
            return CertificateType(rawValue: self.managedType ?? "regular") ?? .regular
        }
    }

    var grade: Int {
        set(newGrade) {
            self.managedGrade = newGrade as NSNumber?
        }
        get {
            return managedGrade?.intValue ?? 0
        }
    }

    var urlString: String? {
        set(newUrlString) {
            self.managedURL = newUrlString
        }
        get {
            return self.managedURL
        }
    }

    var isPublic: Bool? {
        get {
            return self.managedisPublic?.boolValue ?? false
        }
        set(value) {
            self.managedisPublic = value as NSNumber?
        }
    }

    var course: Course? {
        get {
            return self.managedCourse
        }
        set(value) {
            self.managedCourse = value
        }
    }
}
