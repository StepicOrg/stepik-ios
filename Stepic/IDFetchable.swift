//
//  IDFetchable.swift
//  Stepic
//
//  Created by Ostrenkiy on 02.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

protocol IDFetchable: JSONSerializable where IdType: CoreDataRepresentable {

    static func getId(json: JSON) -> IdType?
    static func fetchAsync(ids: [IdType]) -> Promise<[Self]>
}

extension IDFetchable {
    static func getId(json: JSON) -> IdType? {
        if IdType.self == Int.self {
            return json["id"].int as? Self.IdType
        }
        if IdType.self == String.self {
            return json["id"].string as? Self.IdType
        }
        return nil
    }

    static func fetchAsync(ids: [IdType]) -> Promise<[Self]> {
        return DatabaseFetchService.fetchAsync(entityName: String(describing: Self.self), ids: ids)
    }
}

protocol CoreDataRepresentable {
    var fetchValue: CVarArg { get }
}

extension String: CoreDataRepresentable {
    var fetchValue: CVarArg {
        return self
    }
}

extension Int: CoreDataRepresentable {
    var fetchValue: CVarArg {
        return self as NSNumber
    }
}
