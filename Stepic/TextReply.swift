//
//  TextReply.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class TextReply: NSObject, Reply {
    
    var text : String
    
    init(text: String) {
        self.text = text
    }
    
    required init(json: JSON) {
        text = json["text"].stringValue
        super.init()
    }
    
    var dictValue : [String : NSObject] {
        return ["text" : text as NSObject]
    }
}

