//
//  ChoiceDataset.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChoiceDataset: NSObject, Dataset {

    var isMultipleChoice: Bool
    var options: [String]

    required init(json: JSON) {
        isMultipleChoice = json["is_multiple_choice"].boolValue
        options = json["options"].arrayValue.map({return $0.stringValue})

        super.init()
    }

}
