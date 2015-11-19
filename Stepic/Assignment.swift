//
//  Assignment.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Assignment: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].intValue
        stepId = json["step"].intValue
        unitId = json["unit"].intValue
    }
    
    func update(json json: JSON) {
        initialize(json)
    }

}
