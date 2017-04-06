//
//  Step.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import MagicalRecord

class Step: NSManagedObject, JSONInitializable {

    typealias idType = Int

    convenience required init(json: JSON){
        self.init()
        initialize(json)
        block = Block(json: json["block"])
    }
    
    func initialize(_ json: JSON) {
        id = json["id"].intValue
        position = json["position"].intValue
        status = json["status"].stringValue
        progressId = json["progress"].stringValue
        hasSubmissionRestrictions = json["has_submissions_restrictions"].boolValue
        
        if let doesReview = json["actions"]["do_review"].string {
            hasReview = (doesReview != "")
        } else {
            hasReview = false
        }
        discussionsCount = json["discussions_count"].int
        discussionProxyId = json["discussion_proxy"].string
        lessonId = json["lesson"].intValue
        
    }
    
    func update(json: JSON) {
        initialize(json)
        block.update(json: json["block"])
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].intValue
    }
    
    var hasReview : Bool = false

    static func getStepWithId(_ id: Int, unitId: Int? = nil) -> Step? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Step")
        
        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)        
        
        request.predicate = predicate
        
        do {
            guard let results = try CoreDataHelper.instance.context.fetch(request) as? [Step] else {
                return nil
            }
            
            if let unitId = unitId {
                if let step = results.filter({ return $0.lesson?.unit?.id == unitId }).first {
                    return step
                } else {
                    return results.first
                }
            } else {
                return results.first
            }
//            (results as? [Step])?.forEach {
//                print("\($0.lesson?.unit?.id)")
//            }
        }
        catch {
            return nil
        }
//        return Step.MR_findFirstWithPredicate(NSPredicate(format: "managedId == %@", id as NSNumber))
    }
    
}
