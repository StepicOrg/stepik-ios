//
//  FillBlanksDataset.swift
//  Stepic
//
//  Created by Alexander Karpov on 02.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class FillBlanksDataset: Dataset {
    var components : [FillBlanksComponent] = []
    required init(json: JSON) {  
        components = json["components"].arrayValue.map({
            return FillBlanksComponent(json: $0)
        })
    }
}



struct FillBlanksComponent {
    var text: String
    var type: FillBlanksComponentType
    var options: [String]
    
    init(json: JSON) {
        text = json["text"].stringValue
        if text.indexOf("<br>") == 0 {
            text.removeSubrange(text.startIndex...text.index(text.startIndex, offsetBy: 4))
        }
        type = FillBlanksComponentType(rawValue: json["type"].stringValue) ?? .text
        options = json["options"].arrayValue.map({
            return $0.stringValue
        })
    }
}

enum FillBlanksComponentType : String {
    case text = "text"
    case input = "input"
    case select = "select"
}
