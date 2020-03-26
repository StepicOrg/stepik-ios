//
//  StepikModelView.swift
//  Stepic
//
//  Created by Ostrenkiy on 21.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

final class StepikModelView: JSONSerializable {
    typealias IdType = Int

    var id: Int = 0
    var step: Int = 0
    var assignment: Int?

    var json: JSON {
        var dict: JSON = ["step": self.step]
        if let assignment = self.assignment {
            try? dict.merge(with: ["assignment": assignment])
        }
        return dict
    }

    init(step: Int, assignment: Int?) {
        self.step = step
        self.assignment = assignment
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.step = json["step"].intValue
        self.assignment = json["assignment"].int
    }

    func hasEqualId(json: JSON) -> Bool { false }
}
