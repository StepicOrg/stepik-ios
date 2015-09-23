//
//  StepicAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class StepicAPI: NSObject {
    static var shared = StepicAPI()
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private override init() {}
    
    var _token : StepicToken?
    
    var token : StepicToken? {
        set(newToken) {
            defaults.setValue(newToken?.accessToken, forKey: "access_token")
            defaults.setValue(newToken?.refreshToken, forKey: "refresh_token")
            defaults.setValue(newToken?.tokenType, forKey: "token_type")
            defaults.synchronize()
        }
        
        get {
            if _token == nil {
                if let accessToken = defaults.valueForKey("access_token"),
                let refreshToken = defaults.valueForKey("refresh_token"),
                let tokenType = defaults.valueForKey("token_type") {
                    return StepicToken(accessToken: accessToken as! String, refreshToken: refreshToken as! String, tokenType: tokenType as! String)
                } else {
                    return nil
                }
            } else {
                return _token!
            }
        }
    }
    
    var isAuthorized : Bool {
        return token != nil
    }
}
