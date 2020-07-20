//
//  Certificate+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

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
    @NSManaged var managedIsWithScore: NSNumber?
    @NSManaged var managedCourse: Course?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Certificate", in: CoreDataHelper.shared.context)!
    }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    static var fetchRequest: NSFetchRequest<Certificate> {
        NSFetchRequest<Certificate>(entityName: "Certificate")
    }

    convenience init() {
        self.init(entity: Certificate.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
             managedId?.intValue ?? -1
        }
    }

    var courseId: Int {
        set(newId) {
            self.managedCourseId = newId as NSNumber?
        }
        get {
             managedCourseId?.intValue ?? -1
        }
    }

    var userId: Int {
        set(newId) {
            self.managedUserId = newId as NSNumber?
        }
        get {
             managedUserId?.intValue ?? -1
        }
    }

    var issueDate: Date? {
        set(date) {
            self.managedIssueDate = date
        }
        get {
             managedIssueDate
        }
    }

    var updateDate: Date? {
        set(date) {
            self.managedUpdateDate = date
        }
        get {
             managedUpdateDate
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
             CertificateType(rawValue: self.managedType ?? "regular") ?? .regular
        }
    }

    var grade: Int {
        set(newGrade) {
            self.managedGrade = newGrade as NSNumber?
        }
        get {
             managedGrade?.intValue ?? 0
        }
    }

    var urlString: String? {
        set(newUrlString) {
            self.managedURL = newUrlString
        }
        get {
             self.managedURL
        }
    }

    var isPublic: Bool? {
        get {
             self.managedisPublic?.boolValue ?? false
        }
        set(value) {
            self.managedisPublic = value as NSNumber?
        }
    }

    var isWithScore: Bool {
        get {
            self.managedIsWithScore?.boolValue ?? false
        }
        set {
            self.managedIsWithScore = NSNumber(value: newValue)
        }
    }

    var course: Course? {
        get {
             self.managedCourse
        }
        set(value) {
            self.managedCourse = value
        }
    }
}
