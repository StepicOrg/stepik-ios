//
//  JSONInitializable.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol JSONInitializable {

    associatedtype idType : Equatable

    init(json: JSON)
    func update(json: JSON)

    var id: idType {get set}

    func hasEqualId(json: JSON) -> Bool
}
