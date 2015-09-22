//
//  StepicToken.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class StepicToken: NSObject {
    let accessToken : String!
    let refreshToken : String!
    let tokenType : String!
    
    init(json: JSON) {
        accessToken = json["access_token"].stringValue
        refreshToken = json["refresh_token"].stringValue
        tokenType = json["token_type"].stringValue
    }
    
    init(accessToken: String, refreshToken: String, tokenType: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
    }
}