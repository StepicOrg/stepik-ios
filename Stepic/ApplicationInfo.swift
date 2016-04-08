//
//  ApplicationInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

struct ApplicationInfo {
    var clientId : String
    var clientSecret: String
    var credentials : String
    var redirectUri : String
    
    init(clientId id: String, clientSecret secret: String, credentials c : String, redirectUri uri: String) {
        self.clientId = id
        self.clientSecret = secret
        self.credentials = c
        self.redirectUri = uri
    }
}