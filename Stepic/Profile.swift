//
//  Profile.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Profile: NSObject {
    
    var firstName : String
    var lastName : String
    var avatarURL : String
    
    
    init(json: JSON) {
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        avatarURL = json["avatar"].stringValue
    }
}
