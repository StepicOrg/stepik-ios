//
//  CourseReviewSummary.swift
//  Stepic
//
//  Created by Ostrenkiy on 29.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class CourseReviewSummary: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = Int

    var rating: Int {
        self.count > 0 ? Int(round(self.average)) : 0
    }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.average = json[JSONKey.average.rawValue].floatValue
        self.count = json[JSONKey.count.rawValue].intValue
        self.distribution = json[JSONKey.distribution.rawValue].arrayValue.compactMap(\.int)
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    enum JSONKey: String {
        case id
        case average
        case count
        case distribution
    }
}
