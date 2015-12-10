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
            if newToken == nil || newToken?.accessToken == ""  {
                //Delete enrolled information
                TabsInfo.myCoursesIds = []
                let c = Course.getAllCourses(enrolled: true)
                for course in c {
                    course.enrolled = false
                }
                StepicAPI.shared.user = nil
                //Show sign in controller
                ControllerHelper.showLaunchController(true)
                AnalyticsHelper.sharedHelper.changeSignIn()
            } else {
                print("\ndid set new token -> \(newToken!.accessToken)\n")
                didRefresh = true
            }
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
    
    var authorizationType : AuthorizationType {
        get {
            if let typeRaw = defaults.valueForKey("authorization_type") as? Int {
                return AuthorizationType(rawValue: typeRaw)!
            } else {
                return AuthorizationType.None
            }
        }
        
        set(type) {
            defaults.setValue(type.rawValue, forKey: "authorization_type")
            defaults.synchronize()
        }
    }
    
    var didRefresh : Bool = false
    
    var userId : Int? {
        set(id) {
            defaults.setValue(id, forKey: "user_id")
            defaults.synchronize()
        }
        get {
            if let id = defaults.valueForKey("user_id") as? Int {
                return id
            } else {
                return nil
            }
        }
    }
    
    var user : User? {
        didSet {
            userId = user?.id
        }
    }
}

enum AuthorizationType: Int {
    case None = 0, Password, Code
}
