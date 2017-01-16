//
//  MatchingDataset.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.01.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class MatchingDataset: Dataset {
    typealias Pair = (first: String, second: String) 
    var pairs : [Pair]
    
    var firstValues : [String] {
        return pairs.map({return $0.first})
    }
    
    var secondValues : [String] {
        return pairs.map({return $0.second})
    }
    
    required init(json: JSON) {
        pairs = json["pairs"].arrayValue.map({
            pairJSON in
            return (first: pairJSON["first"].stringValue, second: pairJSON["second"].stringValue)
        })
    }
}
