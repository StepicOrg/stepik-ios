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
    convenience required init(json: JSON) {
        self.init()
        print("Initializing the LastStep object from JSON: \(json)")
        id = json["id"].stringValue
        unitId = json["unit"].int
        stepId = json["step"].int
//        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        id = json["id"].stringValue
        unitId = json["unit"].int
        stepId = json["step"].int
    }
    
    func update(unitId: Int?, stepId: Int?) {
        self.unitId = unitId
        self.stepId = stepId
    }
    
    convenience init(unitId: Int?, stepId: Int?) {
        self.init()
        self.unitId = unitId
        self.stepId = stepId
        self.id = nil
    }

    
    func update(json: JSON) {
        initialize(json)
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].stringValue
    }
    
}
