//
//  MathReply.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class MathReply: NSObject, Reply {
    var formula: String

    init(formula: String) {
        self.formula = formula
    }

    required init(json: JSON) {
        formula = json["formula"].stringValue
        super.init()
    }

    var dictValue: [String: Any] { ["formula": formula] }
}
