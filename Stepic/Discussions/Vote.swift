//
//  Vote.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum VoteValue: String {
    case epic
    case abuse
}

final class Vote: JSONSerializable {
    var id: String
    var value: VoteValue?

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.value.rawValue: self.value?.rawValue ?? NSNull()
        ]
    }

    private init() {
        self.id = ""
    }

    required convenience init(json: JSON) {
        self.init()
        self.update(json: json)
    }

    init(id: Vote.IdType, value: VoteValue?) {
        self.id = id
        self.value = value
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        if let voteValue = json[JSONKey.value.rawValue].string {
            self.value = VoteValue(rawValue: voteValue)
        }
    }

    enum JSONKey: String {
        case id
        case value
    }
}
