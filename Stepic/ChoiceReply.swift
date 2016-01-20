//
//  ChoiceReply.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChoiceReply: NSObject, Reply {
    var choices : [Bool]
    
    required init(json: JSON) {
        choices = json["choices"].arrayValue.map({return $0.boolValue})
        super.init()
    }
}
