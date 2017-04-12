//
//  Meta.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Meta {
    var hasNext: Bool
    var hasPrev: Bool
    var page: Int
    
    init(hasNext: Bool, hasPrev: Bool, page: Int) {
        self.hasNext = hasNext
        self.hasPrev = hasPrev
        self.page = page
    }
    
    init(json: JSON) {
        hasNext = json["has_next"].boolValue
        hasPrev = json["has_previous"].boolValue
        page = json["page"].intValue
    }
}
