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

// Insert code here to add functionality to your managed object subclass
    convenience required init(json: JSON){
        self.init()
        initialize(json)
        block = Block(json: json["block"])
    }
    
    func initialize(json: JSON) {
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
    }
    
    func update(json json: JSON) {
        initialize(json)
        block.update(json: json["block"])
    }
    
    var hasReview : Bool = false

    static func getStepWithId(id: Int) -> Step? {
        return Step.MR_findFirstWithPredicate(NSPredicate(format: "managedId == %@", id as NSNumber))
    }
    
}
