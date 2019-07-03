//
//  Vote.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class Vote: JSONSerializable {
    func update(json: JSON) {
        id = json["id"].stringValue
        if let v = json["value"].string {
            value = VoteValue(rawValue: v)
        }
    }

    var id: String
    var value: VoteValue?

    private init() {
        id = ""
    }

    convenience required init(json: JSON) {
        self.init()
        update(json: json)
    }

    init(id: String, value: VoteValue?) {
        self.id = id
        self.value = value
    }

    var json: JSON {
        return [
            "id": id,
            "value": value?.rawValue ?? NSNull()
        ]
    }
}

enum VoteValue: String {
    case epic
    case abuse
}
