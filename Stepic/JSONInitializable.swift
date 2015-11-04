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
    
    init(json: JSON)
    func update(json json: JSON)
    
    var id : Int {get set}
}
