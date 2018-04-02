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

class LastStep: NSManagedObject, JSONSerializable {

    typealias IdType = String

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
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

    convenience init(id: String, unitId: Int?, stepId: Int?) {
        self.init()
        self.unitId = unitId
        self.stepId = stepId
        self.id = ""
    }

    func update(json: JSON) {
        initialize(json)
    }
}
