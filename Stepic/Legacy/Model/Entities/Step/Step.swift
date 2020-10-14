//
//  Step.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class Step: NSManagedObject, IDFetchable {
    typealias IdType = Int

    var canEdit = false
    var hasReview = false

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
        self.block = Block(json: json[JSONKey.block.rawValue])
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.position = json[JSONKey.position.rawValue].intValue
        self.status = json[JSONKey.status.rawValue].stringValue
        self.progressID = json[JSONKey.progress.rawValue].stringValue
        self.hasSubmissionRestrictions = json[JSONKey.hasSubmissionsRestrictions.rawValue].boolValue

        if let doReview = json[JSONKey.actions.rawValue][JSONKey.doReview.rawValue].string {
            self.hasReview = (doReview != "")
        } else {
            self.hasReview = false
        }

        self.discussionsCount = json[JSONKey.discussionsCount.rawValue].int
        self.discussionProxyID = json[JSONKey.discussionProxy.rawValue].string
        self.discussionThreadsArray = json[JSONKey.discussionThreads.rawValue].arrayObject as? [String]

        self.maxSubmissionsCount = json[JSONKey.maxSubmissionsCount.rawValue].int
        self.lessonID = json[JSONKey.lesson.rawValue].intValue
        self.passedByCount = json[JSONKey.passedBy.rawValue].intValue
        self.correctRatio = json[JSONKey.correctRatio.rawValue].floatValue

        if let editInstructions = json[JSONKey.actions.rawValue][JSONKey.editInstructions.rawValue].string {
            self.canEdit = (editInstructions != "")
        } else {
            self.canEdit = false
        }

        if let options = self.options {
            options.update(json: json[JSONKey.block.rawValue][JSONKey.options.rawValue])
        } else {
            self.options = StepOptions(json: json[JSONKey.block.rawValue][JSONKey.options.rawValue])
        }
    }

    func update(json: JSON) {
        self.initialize(json)
        self.block.update(json: json["block"])
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? Step else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.id != object.id { return false }
        if self.position != object.position { return false }
        if self.status != object.status { return false }
        if self.progressID != object.progressID { return false }
        if self.hasSubmissionRestrictions != object.hasSubmissionRestrictions { return false }
        if self.hasReview != object.hasReview { return false }
        if self.discussionsCount != object.discussionsCount { return false }
        if self.discussionProxyID != object.discussionProxyID { return false }
        if self.discussionThreadsArray != object.discussionThreadsArray { return false }
        if self.maxSubmissionsCount != object.maxSubmissionsCount { return false }
        if self.lessonID != object.lessonID { return false }
        if self.passedByCount != object.passedByCount { return false }
        if self.correctRatio != object.correctRatio { return false }
        if self.canEdit != object.canEdit { return false }

        if let options = self.options {
            if !options.equals(object.options) { return false }
        } else if object.options != nil {
            return false
        }

        return true
    }

    static func getStepWithID(_ id: IdType, unitID: Unit.IdType? = nil) -> Step? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Step")
        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)
        request.predicate = predicate

        do {
            guard let results = try CoreDataHelper.shared.context.fetch(request) as? [Step] else {
                return nil
            }

            if let unitID = unitID {
                if let step = results.filter({ $0.lesson?.unit?.id == unitID }).first {
                    return step
                } else {
                    return results.first
                }
            } else {
                return results.first
            }
        } catch {
            return nil
        }
    }

    enum JSONKey: String {
        case id
        case block
        case options
        case position
        case status
        case progress
        case hasSubmissionsRestrictions = "has_submissions_restrictions"
        case actions
        case doReview = "do_review"
        case maxSubmissionsCount = "max_submissions_count"
        case lesson
        case editInstructions = "edit_instructions"
        case passedBy = "passed_by"
        case correctRatio = "correct_ratio"
        case discussionsCount = "discussions_count"
        case discussionProxy = "discussion_proxy"
        case discussionThreads = "discussion_threads"
    }
}
