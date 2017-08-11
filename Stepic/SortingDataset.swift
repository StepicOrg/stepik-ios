//
//  SortingDataset.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class SortingDataset: NSObject, Dataset {
    var options: [String]

    required init(json: JSON) {
        options = json["options"].arrayValue.map({return $0.stringValue})
        super.init()
    }
}
