//
//  AuthManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AuthManager : NSObject {
    static var sharedManager = AuthManager()
    
    private override init() {}
    
    
    func logInWithCode(code: String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) -> Request? {
        
        if StepicApplicationsInfo.social == nil {
            failure(error: NSError.noAppWithCredentials as ErrorType)
            return nil 
        }
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(StepicApplicationsInfo.social!.credentials)"
        ]
        
        let params = [
            "grant_type" : "authorization_code",
            "code" : code,
            "redirect_uri" : StepicApplicationsInfo.social!.redirectUri
        ]
        
        return Alamofire.request(.POST, "\(StepicApplicationsInfo.oauthURL)/token/", parameters: params, headers: headers).responseSwiftyJSON({
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
            AuthInfo.shared.authorizationType = AuthorizationType.Code
            success(token: token)
        })
        
    }
    
    func logInWithUsername(username : String, password : String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) -> Request? {
        
        if StepicApplicationsInfo.password == nil {
            failure(error: NSError.noAppWithCredentials as ErrorType)
            return nil 
        }
        
        // Specifying the Headers we need
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(StepicApplicationsInfo.password!.credentials)"
        ]
        
        let params = [
            "grant_type" : "password",
            "password" : password,
            "username" : username
        ]
        
        
        return Alamofire.request(.POST, "\(StepicApplicationsInfo.oauthURL)/token/", parameters: params, headers: headers).responseSwiftyJSON({
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
            AuthInfo.shared.authorizationType = AuthorizationType.Password
            success(token: token)
        })
    }
    
    func refreshTokenWith(refresh_token : String, success : (token: StepicToken) -> Void, failure : (error : ErrorType) -> Void) -> Request? {
        
        var credentials = ""
        switch AuthInfo.shared.authorizationType {
        case .None:
            failure(error: ConnectionError.TokenRefreshError)
            return nil
        case .Code:
            if StepicApplicationsInfo.social == nil {
                failure(error: NSError.noAppWithCredentials as ErrorType)
                return nil 
            }
            credentials = StepicApplicationsInfo.social!.credentials
        case .Password:
            if StepicApplicationsInfo.password == nil {
                failure(error: NSError.noAppWithCredentials as ErrorType)
                return nil 
            }
            credentials = StepicApplicationsInfo.password!.credentials
        }
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(credentials)"
        ]
        
        let params = [
            "grant_type" : "refresh_token",
            "refresh_token" : refresh_token]
        
        return Alamofire.request(.POST, "\(StepicApplicationsInfo.oauthURL)/token/", parameters: params, headers: headers).responseSwiftyJSON({
            (_,_, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }

            let token : StepicToken = StepicToken(json: json)
            
            if token.accessToken == "" {
                failure(error: NSError.tokenRefreshError)
                return
            }
            
            success(token: token)
        })
        
    }
    
    func autoRefreshToken(success success : (Void -> Void)? = nil, failure : (Void -> Void)? = nil) -> Request? {
        
        if AuthInfo.shared.didRefresh {
            success?()
            return nil
        }
        
        return refreshTokenWith(AuthInfo.shared.token!.refreshToken, success: {
            (t) in
            
            AuthInfo.shared.token = t
            success?()
            }, failure : {
                error in
                print("error while auto refresh token")
                failure?()
        })
    }
    
    func joinCourseWithId(courseId: Int, delete: Bool = false, success : (Void -> Void), error errorHandler: (String->Void)) -> Request? {
        let headers : [String : String] = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(AuthInfo.shared.token!.accessToken)"
        ]
        
        let params : [String : AnyObject] = [
            "enrollment" : [
                "course" : "\(courseId)"
            ]
        ]
        
        //        params["access_token"] = AuthInfo.shared.token!.accessToken
        
        if !delete {
            return Alamofire.request(.POST, "\(StepicApplicationsInfo.apiURL)/enrollments", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON(completionHandler: {
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
            return Alamofire.request(.DELETE, "\(StepicApplicationsInfo.apiURL)/enrollments/\(courseId)", parameters: params, encoding: .URL, headers: headers).responseSwiftyJSON(completionHandler: {
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
            if cookie.domain.rangeOfString("stepic") != nil || cookie.domain.rangeOfString("stepik") != nil {
                print("Deleting cookie with name: \(cookie.name), value: \(cookie.value)\n")
                storage.deleteCookie(cookie)
            }
        }
    }
    
    func refreshSignUpCookies(completion completion: (String -> Void), error errorHandler: (String -> Void)) -> Request? {
        let stepicURLString = "\(StepicApplicationsInfo.stepicURL)/accounts/signup/?next=/"
        let stepicURL = NSURL(string: stepicURLString)!
        deleteStepicCookiesForSignup()
        //        let d = NSHTTPCookie.requestHeaderFieldsWithCookies((NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(stepicURL)!))
        return Alamofire.request(.GET, stepicURLString, parameters: nil, encoding: .URL).response { 
            (request, response, _, error) -> Void in
            
            if let e = error {
                errorHandler((e as NSError).localizedDescription)
            }
            
            if let r = response {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(r.allHeaderFields as! [String: String], forURL: stepicURL)
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
            } else {
                errorHandler("No response")
            }
        }
        
    }
    
    //TODO: When refactoring code think about this function
    func signUpWith(firstname: String, lastname: String, email: String, password: String, success : (Void -> Void), error errorHandler: ((String?, RegistrationErrorInfo?) -> Void)) {
        refreshSignUpCookies(completion: {
            csrftoken in
            let stepicURLString = "\(StepicApplicationsInfo.stepicURL)/accounts/signup/?next=/"
            let stepicURL = NSURL(string: stepicURLString)!
            var headers : [String : String] = NSHTTPCookie.requestHeaderFieldsWithCookies((NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(stepicURL)!))
            
            headers["Referer"] = "\(StepicApplicationsInfo.stepicURL)/"
            headers["X-CSRFToken"] = csrftoken
                        
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
            Alamofire.request(.POST, "\(StepicApplicationsInfo.apiURL)/users", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON(completionHandler:  
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
                errorHandler(NSLocalizedString("RegistrationError", comment: ""), nil)
        })
    }
}

extension NSError {
    
    static var tokenRefreshError: NSError {
        return NSError(domain: "APIErrorDomain", code: 1337, userInfo:  [NSLocalizedDescriptionKey : "Token refresh error"])
    }
    
    static var noAppWithCredentials : NSError {
        return NSError(domain: "APIErrorDomain", code: 1488, userInfo:  [NSLocalizedDescriptionKey : "Not registered application with given credential type"])
    }
}

extension Int {
    func isSuccess() -> Bool {
        return "\(self)".characters.first == "2"
    }
}
