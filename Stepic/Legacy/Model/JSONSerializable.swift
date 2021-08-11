//
//  JSONSerializable.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

typealias JSONDictionary = [String: Any]

protocol JSONSerializable: Identifiable {
    associatedtype IdType: Equatable

    var id: IdType { get set }
    var json: JSON { get }

    init(json: JSON)

    func update(json: JSON)
    func hasEqualId(json: JSON) -> Bool
}

extension JSONSerializable {
    var json: JSON { [] }

    func hasEqualId(json: JSON) -> Bool {
        if IdType.self == Int.self {
            return (json["id"].int as? Self.IdType) == self.id
        }
        if IdType.self == String.self {
            return (json["id"].string as? Self.IdType) == self.id
        }
        return false
    }
}
