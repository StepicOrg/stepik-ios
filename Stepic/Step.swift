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
    }
    
    func update(json json: JSON) {
        initialize(json)
        block.update(json: json["block"])
    }
    
}
