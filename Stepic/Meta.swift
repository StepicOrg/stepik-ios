//
//  Meta.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Meta: NSObject {
    var hasNext: Bool
    var hasPrev: Bool
    var page: Int
    
    init(json: JSON) {
        hasNext = json["has_next"].boolValue
        hasPrev = json["has_previous"].boolValue
        page = json["page"].intValue
    }
}
