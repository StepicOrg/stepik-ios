//
//  CourseReviewSummary.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CourseReviewSummary: NSManagedObject, JSONSerializable {

    typealias idType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        average = json["average"].floatValue
        count = json["count"].intValue
        distribution = json["distribution"].arrayObject as! [Int]
    }

    func update(json: JSON) {
        initialize(json)
    }

    var json: JSON {
        return []
    }

    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].intValue
    }
}
