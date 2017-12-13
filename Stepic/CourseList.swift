//
//  CourseList.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import PromiseKit

class CourseList: NSManagedObject, JSONInitializable {
    typealias idType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        listDescription = json["description"].stringValue
        position = json["position"].intValue
        languageString = json["language"].stringValue
        coursesArray = json["courses"].arrayObject as! [Int]
    }

    func update(json: JSON) {
        initialize(json)
    }

    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].int
    }

    var language: ContentLanguage {
        return ContentLanguage(languageString: languageString)
    }

    class func recoverAsync(ids: [Int]) -> Promise<[CourseList]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseList")
        let descriptor = NSSortDescriptor(key: "managedPosition", ascending: true)

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        let idCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)

        request.predicate = idCompoundPredicate
        request.sortDescriptors = [descriptor]

        return Promise<[CourseList]> {
            fulfill, _ in
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request, completionBlock: {
                results in
                guard let courseLists = results.finalResult as? [CourseList] else {
                    fulfill([])
                    return
                }
                fulfill(courseLists)
            })
            _ = try? CoreDataHelper.instance.context.execute(asyncRequest)
        }
    }

    class func recover(ids: [Int]) -> [CourseList] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseList")
        let descriptor = NSSortDescriptor(key: "managedPosition", ascending: false)

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        let idCompoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)

        request.predicate = idCompoundPredicate
        request.sortDescriptors = [descriptor]

        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return results as? [CourseList] ?? []
        } catch {
            return []
        }
    }
}
