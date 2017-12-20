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
    var components: [FillBlanksComponent] = []
    required init(json: JSON) {
        components = json["components"].arrayValue.map({
            FillBlanksComponent(json: $0)
        })
    }
}

struct FillBlanksComponent {
    var text: String
    var type: FillBlanksComponentType
    var options: [String]

    fileprivate mutating func removeEmptyLine() {
        let emptyTags = ["<br>", "<br/>", "<br />"]
        for tag in emptyTags {
            if text.indexOf(tag) == 0 {
                text.removeSubrange(text.startIndex...text.index(text.startIndex, offsetBy: tag.count))
                return
            }
        }
    }

    init(json: JSON) {
        text = json["text"].stringValue
        type = FillBlanksComponentType(rawValue: json["type"].stringValue) ?? .text
        options = json["options"].arrayValue.map({
            $0.stringValue
        })
        self.removeEmptyLine()
    }
}

enum FillBlanksComponentType: String {
    case text = "text"
    case input = "input"
    case select = "select"
}
