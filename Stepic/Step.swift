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

    static func getStepWithId(_ id: Int) -> Step? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Step")
        
        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)        
        
        request.predicate = predicate
        
        do {
            let results = try CoreDataHelper.instance.context.fetch(request) 
            return (results as? [Step])?.first
        }
        catch {
            return nil
        }
//        return Step.MR_findFirstWithPredicate(NSPredicate(format: "managedId == %@", id as NSNumber))
    }
    
}
