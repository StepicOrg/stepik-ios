//
//  NumberReply.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class NumberReply: NSObject, Reply {
    var number: String

    init(number: String) {
        self.number = number
    }

    required init(json: JSON) {
        number = json["number"].stringValue
        super.init()
    }

    var dictValue: [String: Any] { ["number": number] }
}
