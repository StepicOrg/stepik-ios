//
//  Certificate+CoreDataClass.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc
final class Certificate: NSManagedObject, IDFetchable {
    typealias IdType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json["id"].intValue
        self.userId = json["user"].intValue
        self.courseId = json["course"].intValue
        self.issueDate = Parser.sharedParser.dateFromTimedateJSON(json["issue_date"])
        self.updateDate = Parser.sharedParser.dateFromTimedateJSON(json["update_date"])
        self.grade = json["grade"].intValue
        self.type = CertificateType(rawValue: json["type"].stringValue) ?? .regular
        self.urlString = json["url"].string
        self.isPublic = json["is_public"].bool
    }

    func update(json: JSON) {
        initialize(json)
    }

    class func fetch(_ ids: [Int], user userId: Int) -> [Certificate] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Certificate")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        let idCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        let userPredicate = NSPredicate(format: "managedUserId == %@", userId as NSNumber)

        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [idCompoundPredicate, userPredicate])

        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return results as! [Certificate]
        } catch {
            return []
        }
    }

    //TODO: Refactor this action to protocol extension when refactoring CoreData
    static func deleteAll() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Certificate")
        do {
            let results = try CoreDataHelper.instance.context.fetch(request) as? [Certificate]
            for obj in results ?? [] {
                CoreDataHelper.instance.deleteFromStore(obj)
            }
        } catch {
            print("certificate: couldn't delete all certificates!")
        }
    }
}
