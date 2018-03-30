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

protocol IDFetchable: JSONSerializable {
    static func getId(json: JSON) -> idType?
    static func fetchAsync(ids: [idType]) -> Promise<[Self]>
}

extension IDFetchable {
    static func fetchAsync(ids: [idType]) -> Promise<[Self]> {
        return DatabaseFetchService.fetchAsync(entityName: String(describing: Self.self), ids: ids)
    }
}
