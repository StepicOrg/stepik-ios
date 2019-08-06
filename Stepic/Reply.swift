//
//  Reply.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Reply: CustomStringConvertible {
    var dictValue: [String: Any] { get }
    init(json: JSON)
}

extension Reply {
    var description: String {
        return "Reply(\(self.dictValue))"
    }
}
