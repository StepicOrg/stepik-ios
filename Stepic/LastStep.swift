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
    
    typealias idType = String
    
    // Insert code here to add functionality to your managed object subclass
    convenience required init(json: JSON){
        self.init()
        print("Initializing the LastStep object from JSON: \(json)")
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        self.id = json["id"].stringValue
        self.unitId = json["unit"].int
        self.stepId = json["step"].int
    }
    
    func initialize(unitId: Int?, stepId: Int?) {
        self.unitId = unitId
        self.stepId = stepId
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].stringValue
    }
    
}
