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
    
    private func deleteStepicCookiesForSignup() {
        //        let stepicURL = NSURL(string: "https://stepic.org/accounts/signup/?next=/")!
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies ?? [] {
            if cookie.domain.rangeOfString("stepic") != nil {
                print("Deleting cookie with name: \(cookie.name), value: \(cookie.value)\n")
                storage.deleteCookie(cookie)
            }
        }
    }
    
    func refreshSignUpCookies(completion completion: (String -> Void), error errorHandler: (String -> Void)){
        let stepicURL = NSURL(string: "https://stepic.org/accounts/signup/?next=/")!
        deleteStepicCookiesForSignup()
        //        let d = NSHTTPCookie.requestHeaderFieldsWithCookies((NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(stepicURL)!))
        Alamofire.request(.GET, "https://stepic.org/accounts/signup/?next=/", parameters: nil, encoding: .URL).response { 
            (request, response, _, error) -> Void in
            
            if let e = error {
                errorHandler((e as NSError).localizedDescription)
            }
            
            let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response!.allHeaderFields as! [String: String], forURL: stepicURL)
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: stepicURL, mainDocumentURL: nil)
            
            //            for cookie in cookies {
            //                print("Got new cookie with name: \(cookie.name), value: \(cookie.value)\n")
            //            }
            
            for cookie in cookies {
                if cookie.name == "csrftoken" {
                    completion(cookie.value)
                    return
                }
            }
            
            errorHandler("No cookie for csrftoken")
        }
        
    }
    
    func signUpWith(firstname: String, lastname: String, email: String, password: String, success : (Void -> Void), error errorHandler: ((String?, RegistrationErrorInfo?) -> Void)) {
        refreshSignUpCookies(completion: {
            csrftoken in
            let stepicURL = NSURL(string: "https://stepic.org/accounts/signup/?next=/")!
            var headers : [String : String] = NSHTTPCookie.requestHeaderFieldsWithCookies((NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(stepicURL)!))
            
            headers["Referer"] = "https://stepic.org/"
            headers["X-CSRFToken"] = csrftoken
            
            //        print(headers)
            
            let params : [String : AnyObject] = 
            ["user" :
                [
                    "first_name" : firstname,
                    "last_name" : lastname,
                    "email" : email,
                    "password" : password,
                ]
            ]
            
            print("sending request with headers:\n\(headers)\nparams:\n\(params)")
            Alamofire.request(.POST, "https://stepic.org/api/users", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON(completionHandler:  
                { 
                    (request, response, json, error) -> Void in
                    let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response!.allHeaderFields as! [String: String], forURL: stepicURL)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: stepicURL, mainDocumentURL: nil)
                    
                    if let e = (error as? NSError) {
                        let errormsg = "\(e.code)\n\(e.localizedFailureReason ?? "")\n\(e.localizedRecoverySuggestion ?? "")\n\(e.localizedDescription)"
                        
                        errorHandler(errormsg, nil)
                        return
                    }
                    
                    if let r = response {
                        print(r.statusCode)
                        if r.statusCode.isSuccess() {
                            success()
                        } else if r.statusCode == 400 {
                            errorHandler(nil, RegistrationErrorInfo(json: json))
                        }
                    }
            })},error:  { 
                errorMsg in
                errorHandler("error while refreshing csrf token", nil)
        })
    }
}

extension Int {
    func isSuccess() -> Bool {
        return "\(self)".characters.first == "2"
    }
}
