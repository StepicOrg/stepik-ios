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
        
    private func setTokenValue(newToken: StepicToken?) {
        defaults.setValue(newToken?.accessToken, forKey: "access_token")
        defaults.setValue(newToken?.refreshToken, forKey: "refresh_token")
        defaults.setValue(newToken?.tokenType, forKey: "token_type")
        defaults.synchronize()

    }
    
    var token : StepicToken? {
        set(newToken) {
            if newToken == nil || newToken?.accessToken == ""  {
                print("\nsetting new token to nil\n")
                
                //Unregister from notifications
                NotificationRegistrator.sharedInstance.unregisterFromNotifications(completion: {
                    UIThread.performUI{
                        //Delete enrolled information
                        TabsInfo.myCoursesIds = []
                        let c = Course.getAllCourses(enrolled: true)
                        for course in c {
                            course.enrolled = false
                        }
                        CoreDataHelper.instance.save()
                        StepicAPI.shared.user = nil
                        //Show sign in controller
                        ControllerHelper.showLaunchController(true)
                        AnalyticsHelper.sharedHelper.changeSignIn()
                        self.setTokenValue(newToken)
                    }
                })
                
                
            } else {
                print("\nsetting new token -> \(newToken!.accessToken)\n")
                didRefresh = true
                setTokenValue(newToken)
            }
        }
        
        get {
            if let accessToken = defaults.valueForKey("access_token") as? String,
            let refreshToken = defaults.valueForKey("refresh_token") as? String,
            let tokenType = defaults.valueForKey("token_type") as? String {
                print("got accessToken \(accessToken)")
                return StepicToken(accessToken: accessToken, refreshToken: refreshToken, tokenType: tokenType)
            } else {
                return nil
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
