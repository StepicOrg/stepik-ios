//
//  RegistrationErrorInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

struct RegistrationErrorInfo {
    var email : String?
    var firstName : String?
    var lastName : String?
    var password : String?
    
    init(json: JSON) {
        email = json["email"].array?[0].string 
        password = json["password"].array?[0].string 
        firstName = json["first_name"].array?[0].string 
        lastName = json["last_name"].array?[0].string 
    }
}