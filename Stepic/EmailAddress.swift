//
//  EmailAddress.swift
//  Stepic
//
//  Created by Ivan Magda on 10/9/19.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class EmailAddress: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = Int

    convenience required init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json["id"].intValue
        self.userID = json["user"].intValue
        self.email = json["email"].stringValue
        self.isVerified = json["is_verified"].boolValue
        self.isPrimary = json["is_primary"].boolValue
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    var json: JSON {
        return [
            "id": self.id as AnyObject,
            "user": self.userID as AnyObject,
            "email": self.email as AnyObject,
            "is_verified": self.isVerified as AnyObject,
            "is_primary": self.isPrimary as AnyObject
        ]
    }
}
