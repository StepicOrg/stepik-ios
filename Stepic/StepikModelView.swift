//
//  StepikModelView.swift
//  Stepic
//
//  Created by Ostrenkiy on 21.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class StepikModelView: JSONSerializable {
    var id: Int = 0
    var step: Int = 0
    var assignment: Int?
    
    required init(json: JSON) {
        update(json: json)
    }
    
    func update(json: JSON) {
        self.step = json["step"].intValue
        self.assignment = json["assignment"].int
    }
    
    var json: JSON {
        var dict: JSON = ["step": step]
        if let assignment = assignment {
            try! dict.merge(with: ["assignment": assignment])
        }
        return dict
    }
    
    typealias idType = Int
    
    func hasEqualId(json: JSON) -> Bool {
        return false
    }
}
