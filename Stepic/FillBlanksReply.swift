//
//  FillBlanksReply.swift
//  Stepic
//
//  Created by Alexander Karpov on 02.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class FillBlanksReply: Reply {
    
    var blanks : [String]
    
    init(blanks: [String]) {
        self.blanks = blanks
    }
    
    required init(json: JSON) {
        blanks = json["blanks"].arrayValue.map({return $0.stringValue})
    }
    
    var dictValue : [String : Any] {
        return ["blanks" : blanks]
    }
}
