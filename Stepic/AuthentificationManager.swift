//
//  AuthentificationManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AuthentificationManager : NSObject {
    static var sharedManager = AuthentificationManager()
    
    private override init() {}
    
    
    func logInWithCode(code: String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) {
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(StepicApplicationsInfo.social.credentials)"
        ]
        
        let params = [
            "grant_type" : "authorization_code",
            "code" : code,
            "redirect_uri" : StepicApplicationsInfo.social.redirectUri
        ]
        
        Alamofire.request(.POST, "https://stepic.org/oauth2/token/", parameters: params, headers: headers).responseSwiftyJSON({
            (_,_, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            if json["error"] != nil {
                let e = NSError(domain: NSCocoaErrorDomain, code: 1488, userInfo: [NSLocalizedDescriptionKey : json["error_description"].stringValue])
                failure(error: e)
                return
            }
            
            print(json)
            //            print("no error")
            let token : StepicToken = StepicToken(json: json)
            //            print(token.accessToken)
            StepicAPI.shared.authorizationType = AuthorizationType.Code
            success(token: token)
        })
    
    }
    
    func logInWithUsername(username : String, password : String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) {
        
        // Specifying the Headers we need
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(StepicApplicationsInfo.password.credentials)"
        ]
        
        let params = [
            "grant_type" : "password",
            "password" : password,
            "username" : username
        ]
        
        
        Alamofire.request(.POST, "https://stepic.org/oauth2/token/", parameters: params, headers: headers).responseSwiftyJSON({
            (_,_, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            if json["error"] != nil {
                let e = NSError(domain: NSCocoaErrorDomain, code: 1488, userInfo: [NSLocalizedDescriptionKey : json["error_description"].stringValue])
                failure(error: e)
                return
            }
            
            print(json)
//            print("no error")
            let token : StepicToken = StepicToken(json: json)
//            print(token.accessToken)
            StepicAPI.shared.authorizationType = AuthorizationType.Password
            success(token: token)
        })
    }
    
    func refreshTokenWith(refresh_token : String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) {
        
        var credentials = ""
        switch StepicAPI.shared.authorizationType {
        case .None:
            failure(error: ConnectionError.TokenRefreshError)
            return
        case .Code:
            credentials = StepicApplicationsInfo.social.credentials
        case .Password:
            credentials = StepicApplicationsInfo.password.credentials
        }
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(credentials)"
        ]
        
        let params = [
            "grant_type" : "refresh_token",
            "refresh_token" : refresh_token]
        
        Alamofire.request(.POST, "https://stepic.org/oauth2/token/", parameters: params, headers: headers).responseSwiftyJSON({
            (_,_, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
//            print(json)
//            print("no error")
            let token : StepicToken = StepicToken(json: json)
//            print(token.accessToken)
            success(token: token)
        })
        
    }
    
    func autoRefreshToken(success success : (Void -> Void)? = nil, failure : (Void -> Void)? = nil) {
        
        if StepicAPI.shared.didRefresh {
            success?()
            return
        }
        
        refreshTokenWith(StepicAPI.shared.token!.refreshToken, success: {
                (t) in
                StepicAPI.shared.token = t
                success?()
            }, failure : {
            error in
            print("error while auto refresh token")
            failure?()
          })
    }
    
    
    func registerWithFirstName(firstName: String, secondName: String, email: String, password: String) {
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(StepicApplicationsInfo.password.credentials)"
        ]
        
        let params = [
            "first_name" : firstName,
            "second_name" : secondName,
            "email" : email,
            "password" : password
        ]
        
        Alamofire.request(.POST, "https://stepic.org/api/users", parameters: params,  headers: headers).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let _ = error {
                return
            }
            
//            print(json)
            
        })
    }
    
    
    func joinCourseWithId(courseId: Int, delete: Bool = false, success : (Void -> Void), error errorHandler: (String->Void)) {
        let headers : [String : String] = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(StepicAPI.shared.token!.accessToken)"
        ]
        
        let params : [String : AnyObject] = [
            "enrollment" : [
                "course" : "\(courseId)"
            ]
        ]
        
//        params["access_token"] = StepicAPI.shared.token!.accessToken
        
        if !delete {
            Alamofire.request(.POST, "https://stepic.org/api/enrollments", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON(completionHandler: {
                (_, response, json, error) in
                
                if let r = response {
                    if r.statusCode.isSuccess() {
                        success()
                    } else {
                        let s = NSLocalizedString("TryJoinFromWeb", comment: "")
                        errorHandler(s)
                    }
                } else {
                    let s = NSLocalizedString("Error", comment: "")
                    errorHandler(s)
                }
                
//                print("response -> \(response?.statusCode)")
//                print(json)
                
//                if let _ = error {
//                    errorHandler()
//                    return
//                }
//                success()
            })
        } else {
            Alamofire.request(.DELETE, "https://stepic.org/api/enrollments/\(courseId)", parameters: params, encoding: .URL, headers: headers).responseSwiftyJSON(completionHandler: {
                (_, response, json, error) in
                
                if let r = response {
                    if r.statusCode.isSuccess() {
                        success()
                        return
                    }
                }
                
                let s = NSLocalizedString("Error", comment: "")
                errorHandler(s)
            })

        }
        
    }
}

extension Int {
    func isSuccess() -> Bool {
        return "\(self)".characters.first == "2"
    }
}
