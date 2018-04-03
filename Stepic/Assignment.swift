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

@objc
class Assignment: NSManagedObject, JSONSerializable {

    typealias IdType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        stepId = json["step"].intValue
        unitId = json["unit"].intValue
    }

    func update(json: JSON) {
        initialize(json)
    }
}
