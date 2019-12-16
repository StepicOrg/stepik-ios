//
//  MatchingDataset.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.01.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class MatchingDataset: Dataset {
    typealias Pair = (first: String, second: String)

    var pairs: [Pair]

    var firstValues: [String] { self.pairs.map { $0.first } }

    var secondValues: [String] { self.pairs.map { $0.second } }

    required init(json: JSON) {
        self.pairs = json["pairs"].arrayValue.map { pairJSON in
            (first: pairJSON["first"].stringValue, second: pairJSON["second"].stringValue)
        }
    }
}
