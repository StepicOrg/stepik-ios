//
//  Vote.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Vote {
    var id: String
    var value: VoteValue?

    init(json: JSON) {
        id = json["id"].stringValue
        if let v = json["value"].string {
            value = VoteValue(rawValue: v)
        }
    }

    init(id: String, value: VoteValue?) {
        self.id = id
        self.value = value
    }

    var json: [String: AnyObject] {
        let dict: [String: AnyObject] = [
            "id": id as AnyObject,
            "value": value?.rawValue as AnyObject? ?? NSNull()
        ]
        return dict
    }
}

enum VoteValue: String {
    case Epic = "epic", Abuse = "abuse"
}
