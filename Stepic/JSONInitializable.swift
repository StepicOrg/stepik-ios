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

    associatedtype idType: Equatable

    init(json: JSON)
    func update(json: JSON)

    var id: idType {get set}
    var json: JSON { get }

    func hasEqualId(json: JSON) -> Bool
}

extension JSONSerializable {
    func hasEqualId(json: JSON) -> Bool {
        if idType.self == Int.self {
            return (json["id"].int as? Self.idType) == self.id
        }
        if idType.self == String.self {
            return (json["id"].string as? Self.idType) == self.id
        }
        return false
    }

    var json: JSON {
        return []
    }
}

protocol IDFetchable: JSONSerializable {
    static func getId(json: JSON) -> idType?
    static func fetchAsync(ids: [idType]) -> Promise<[Self]>
}

extension IDFetchable {
    static func getId(json: JSON) -> idType? {
        if idType.self == Int.self {
            return json["id"].int as? Self.idType
        }
        if idType.self == String.self {
            return json["id"].string as? Self.idType
        }
        return nil
    }

    static func fetchAsync(ids: [idType]) -> Promise<[Self]> {
        return DatabaseFetchService.fetchAsync(entityName: String(describing: Self.self), ids: ids)
    }
}
