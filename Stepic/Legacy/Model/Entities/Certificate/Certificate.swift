//
//  Certificate+CoreDataClass.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

@objc
final class Certificate: NSManagedObject, IDFetchable {
    typealias IdType = Int

    required convenience init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json["id"].intValue
        self.userId = json["user"].intValue
        self.courseId = json["course"].intValue
        self.issueDate = Parser.shared.dateFromTimedateJSON(json["issue_date"])
        self.updateDate = Parser.shared.dateFromTimedateJSON(json["update_date"])
        self.grade = json["grade"].intValue
        self.type = CertificateType(rawValue: json["type"].stringValue) ?? .regular
        self.urlString = json["url"].string
        self.isPublic = json["is_public"].bool
    }

    func update(json: JSON) {
        initialize(json)
    }

    static func fetch(_ ids: [Int], user userId: Int) -> [Certificate] {
        let request: NSFetchRequest<Certificate> = Certificate.fetchRequest

        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0 as NSNumber) }
        let idCompoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idPredicates)
        let userPredicate = NSPredicate(format: "managedUserId == %@", userId as NSNumber)

        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [idCompoundPredicate, userPredicate])

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return results
        } catch {
            return []
        }
    }
}
