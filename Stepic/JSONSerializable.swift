//
//  JSONSerializable.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON
import PromiseKit

protocol JSONSerializable {

    associatedtype IdType: Equatable

    init(json: JSON)
    func update(json: JSON)

    var id: IdType {get set}
    var json: JSON { get }

    func hasEqualId(json: JSON) -> Bool
}

extension JSONSerializable {
    func hasEqualId(json: JSON) -> Bool {
        if IdType.self == Int.self {
            return (json["id"].int as? Self.IdType) == self.id
        }
        if IdType.self == String.self {
            return (json["id"].string as? Self.IdType) == self.id
        }
        return false
    }

    var json: JSON {
        return []
    }
}
