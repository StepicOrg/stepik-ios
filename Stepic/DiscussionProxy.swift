//
//  DiscussionProxy.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

class DiscussionProxy {

    var discussionIds: [Int]
    var id: String

    init(json: JSON) {
        discussionIds = json["discussions"].arrayValue.flatMap {
            return $0.int
        }
        id = json["id"].stringValue
    }
}
