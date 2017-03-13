//
//  LastStep.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class LastStep: NSManagedObject, JSONInitializable {
    
    // Insert code here to add functionality to your managed object subclass
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        self.id = json["id"].string
        self.unitId = json["unit"].intValue
        self.stepId = json["step"].intValue
    }
    
    func initialize(unitId: Int, stepId: Int) {
        self.unitId = unitId
        self.stepId = stepId
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
}
