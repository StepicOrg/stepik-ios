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
    
    var nextStep : Step? {
        if let l = lesson {
            if let nextIndex = l.steps.indexOf(self)?.successor() {
                if l.steps.count > nextIndex {
                    return l.steps[nextIndex]
                }
            }
        }
        return nil
    }
    
    var previousStep: Step? {
        if let l = lesson {
            if let prevIndex = l.steps.indexOf(self)?.predecessor() {
                return l.steps[prevIndex]
            }
        }
        return nil
    }
    
}
