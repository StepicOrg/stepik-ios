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
        self.id = json[JSONKey.id.rawValue].intValue
        self.userId = json[JSONKey.user.rawValue].intValue
        self.courseId = json[JSONKey.course.rawValue].intValue
        self.issueDate = Parser.dateFromTimedateJSON(json[JSONKey.issueDate.rawValue])
        self.updateDate = Parser.dateFromTimedateJSON(json[JSONKey.updateDate.rawValue])
        self.grade = json[JSONKey.grade.rawValue].intValue
        self.type = CertificateType(rawValue: json[JSONKey.type.rawValue].stringValue) ?? .regular
        self.urlString = json[JSONKey.url.rawValue].string
        self.isPublic = json[JSONKey.isPublic.rawValue].bool
        self.isWithScore = json[JSONKey.isWithScore.rawValue].boolValue
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

    enum JSONKey: String {
        case id
        case user
        case course
        case issueDate = "issue_date"
        case updateDate = "update_date"
        case grade
        case type
        case url
        case isPublic = "is_public"
        case isWithScore = "is_with_score"
    }
}
