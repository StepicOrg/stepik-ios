//
//  Progress.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Progress: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].stringValue
        isPassed = json["is_passed"].boolValue
        score = json["score"].intValue
        cost = json["cost"].intValue
        numberOfSteps = json["n_steps"].intValue
        numberOfStepsPassed = json["n_steps_passed"].intValue
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
}
