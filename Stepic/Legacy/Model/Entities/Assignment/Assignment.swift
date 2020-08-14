//
//  Assignment.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

@objc
final class Assignment: NSManagedObject, IDFetchable {
    typealias IdType = Int

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.unitId = json[JSONKey.unit.rawValue].intValue
        self.stepId = json[JSONKey.step.rawValue].intValue
        self.progressId = json[JSONKey.progress.rawValue].stringValue
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    enum JSONKey: String {
        case id
        case unit
        case step
        case progress
    }
}
