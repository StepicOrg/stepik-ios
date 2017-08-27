//
//  Unit.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import MagicalRecord

class Unit: NSManagedObject, JSONInitializable {

    typealias idType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        position = json["position"].intValue
        isActive = json["is_active"].boolValue
        lessonId = json["lesson"].intValue
        progressId = json["progress"].stringValue
        sectionId = json["section"].intValue

        assignmentsArray = json["assignments"].arrayObject as! [Int]

        beginDate = Parser.sharedParser.dateFromTimedateJSON(json["begin_date"])
        softDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
        hardDeadline = Parser.sharedParser.dateFromTimedateJSON(json["soft_deadline"])
    }

    func update(json: JSON) {
        initialize(json)
    }

    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].intValue
    }

    func loadAssignments(_ completion: @escaping (() -> Void), errorHandler: @escaping (() -> Void)) {
        _ = ApiDataDownloader.assignments.retrieve(ids: self.assignmentsArray, existing: self.assignments, refreshMode: .update, success: {
            newAssignments in
            self.assignments = Sorter.sort(newAssignments, byIds: self.assignmentsArray)
            completion()
            }, error: {
                _ in
                print("Error while downloading assignments")
                errorHandler()
        })
   }

    class func getUnit(id: Int) -> Unit? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Unit")

        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        request.predicate = predicate

        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            if results.count > 1 {
                print("CORE DATA WARNING: More than 1 unit with id \(id)")
            }
            return (results as? [Unit])?.first
        } catch {
            return nil
        }
    }
}
