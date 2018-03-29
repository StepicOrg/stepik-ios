//
//  DiscussionProxy.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class DiscussionProxy: JSONSerializable {
    var discussionIds: [Int] = []
    var id: String = ""

    required init(json: JSON) {
        update(json: json)
    }

    func update(json: JSON) {
        discussionIds = json["discussions"].arrayValue.flatMap {
            $0.int
        }
        id = json["id"].stringValue
    }

    var json: JSON {
        return []
    }

    func hasEqualId(json: JSON) -> Bool {
        return json["id"].string == id
    }
}
