//
//  Enrollment.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Enrollment: JSONSerializable {
    var id: Int = 0
    var course: Int?

    init(courseId: Int) {
        self.course = courseId
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        course = json["course"].int
    }

    var json: JSON {
        return ["course": course ?? ""]
    }
}
