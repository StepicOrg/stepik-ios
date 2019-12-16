//
//  ChoiceReply.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class ChoiceReply: NSObject, Reply {
    var choices: [Bool]

    init(choices: [Bool]) {
        self.choices = choices
    }

    required init(json: JSON) {
        choices = json["choices"].arrayValue.map({ $0.boolValue })
        super.init()
    }

    var dictValue: [String: Any] { ["choices": choices] }
}
