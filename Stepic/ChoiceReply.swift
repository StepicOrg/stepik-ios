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
    
    init(choices: [Bool]) {
        self.choices = choices
    }
    
    required init(json: JSON) {
        choices = json["choices"].arrayValue.map({return $0.boolValue})
        super.init()
    }
    
    var dictValue : [String : NSObject] {
        return ["choices" : choices as NSObject]
    }
}
