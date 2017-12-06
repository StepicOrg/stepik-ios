//
//  SQLReply.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class SQLReply: Reply {
    var code: String

    init(code: String) {
        self.code = code
    }

    required init(json: JSON) {
        code = json["solve_sql"].stringValue
    }

    var dictValue: [String : Any] {
        return ["solve_sql": code]
    }
}
