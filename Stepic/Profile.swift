//
//  Profile.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Profile: NSManagedObject, JSONSerializable {
    typealias idType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        subscribedForMail = json["subscribed_for_mail"].boolValue
    }

    func update(json: JSON) {
        initialize(json)
    }

    var json: JSON {
        return [
            "id": id as AnyObject,
            "first_name": firstName as AnyObject,
            "last_name": lastName as AnyObject,
            "subscribed_for_mail": subscribedForMail as AnyObject
        ]
    }
}
