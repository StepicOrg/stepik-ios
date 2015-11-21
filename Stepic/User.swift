//
//  User.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc
class User: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass
    
    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].intValue
        profile = json["profile"].intValue
        isPrivate = json["is_private"].boolValue
        bio = json["short_bio"].stringValue
        details = json["details"].stringValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        avatarURL = json["avatar"].stringValue
        level = json["level"].intValue
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
    
    
}
