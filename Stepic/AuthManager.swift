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
    
    fileprivate override init() {}
    
    static let oauth = AuthAPI()
    
    func logInWithCode(_ code: String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error : Error) -> Void) -> Request? {
        
        if StepicApplicationsInfo.social == nil {
            failure(NSError.noAppWithCredentials as Error)
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
        
        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/token/", method: .post, parameters: params, headers: headers).responseSwiftyJSON {
            //            (_,_, json, error) in
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response
            
            if let e = error {
                failure(e)
                return
            }
            
            if json["error"] != nil {
                let e = NSError(domain: NSCocoaErrorDomain, code: 1488, userInfo: [NSLocalizedDescriptionKey : json["error_description"].stringValue])
                failure(e)
                return
            }
            
            print(json)
            //            print("no error")
            let token : StepicToken = StepicToken(json: json)
            //            print(token.accessToken)
            AuthInfo.shared.authorizationType = AuthorizationType.code
            success(token)
        }
        
    }
    
    func logInWithUsername(_ username : String, password : String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error : Error) -> Void) -> Request? {
        
        if StepicApplicationsInfo.password == nil {
            failure(NSError.noAppWithCredentials as Error)
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
        
        
        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/token/", method: .post, parameters: params, headers: headers).responseSwiftyJSON({
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response
            
            
            if let e = error {
                failure(e)
                return
            }
            
            if json["error"] != nil {
                let e = NSError(domain: NSCocoaErrorDomain, code: 1488, userInfo: [NSLocalizedDescriptionKey : json["error_description"].stringValue])
                failure(e)
                return
            }
            
            print(json)
            //            print("no error")
            let token : StepicToken = StepicToken(json: json)
            //            print(token.accessToken)
            AuthInfo.shared.authorizationType = AuthorizationType.password
            success(token)
        })
    }
    
    func refreshTokenWith(_ refresh_token : String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error : Error) -> Void) -> Request? {
        func logRefreshError(statusCode: Int?, message: String?) {
            var parameters : [String: NSObject] = [:]
            if let code = statusCode {
                parameters["code"] = code as NSObject?
            }
            if let m = message {
                parameters["message"] = m as NSObject?
            }
            
            AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.tokenRefresh, parameters: parameters)
            
        }
        
        var credentials = ""
        switch AuthInfo.shared.authorizationType {
        case .none:
            failure(ConnectionError.tokenRefreshError)
            return nil
        case .code:
            if StepicApplicationsInfo.social == nil {
                failure(NSError.noAppWithCredentials as Error)
                return nil
            }
            credentials = StepicApplicationsInfo.social!.credentials
        case .password:
            if StepicApplicationsInfo.password == nil {
                failure(NSError.noAppWithCredentials as Error)
                return nil
            }
            credentials = StepicApplicationsInfo.password!.credentials
        }
        
        let headers = [
            "Content-Type" : "application/x-www-form-urlencoded",
            "Authorization" : "Basic \(credentials)"
        ]
        
        let params : Parameters = [
            "grant_type" : "refresh_token",
            "refresh_token" : refresh_token]
        
        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/token/", method: .post, parameters: params, headers: headers).responseSwiftyJSON({
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response
            
            
            if let e = error {
                logRefreshError(statusCode: response?.statusCode, message: "Error \(e.localizedDescription) while refreshing")
                failure(e)
                return
            }
            
            let token : StepicToken = StepicToken(json: json)
            
            if token.accessToken == "" {
                logRefreshError(statusCode: response?.statusCode, message: "Error after getting empty access token")
                failure(NSError.tokenRefreshError)
                return
            }
            
            success(token)
        })
        
    }
    
    func autoRefreshToken(success : ((Void) -> Void)? = nil, failure : ((Void) -> Void)? = nil) -> Request? {
        
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
    
    func joinCourseWithId(_ courseId: Int, delete: Bool = false, success : @escaping ((Void) -> Void), error errorHandler: @escaping ((String)->Void)) -> Request? {
        
        let headers : [String : String] = AuthInfo.shared.initialHTTPHeaders
        
        let params : Parameters = [
            "enrollment" : [
                "course" : "\(courseId)"
            ]
        ]
        
        if !delete {
            return Alamofire.request("\(StepicApplicationsInfo.apiURL)/enrollments", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
                response in
                
                var error = response.result.error
                var json : JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response
                
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
            })
        } else {
            return Alamofire.request("\(StepicApplicationsInfo.apiURL)/enrollments/\(courseId)", method: .delete, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
                response in
                
                var error = response.result.error
                var json : JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response
                
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
    
    //TODO: When refactoring code think about this function
    func signUpWith(_ firstname: String, lastname: String, email: String, password: String, success : @escaping ((Void) -> Void), error errorHandler: @escaping ((String?, RegistrationErrorInfo?) -> Void)) {
        let headers : [String : String] = AuthInfo.shared.initialHTTPHeaders
        
        let params : Parameters =
            ["user" :
                [
                    "first_name" : firstname,
                    "last_name" : lastname,
                    "email" : email,
                    "password" : password,
                ]
        ]
        
        print("sending request with headers:\n\(headers)\nparams:\n\(params)")
        _ = Alamofire.request("\(StepicApplicationsInfo.apiURL)/users", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON(  {
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response
            
            if let e = (error as? NSError) {
                let errormsg = "\(e.code)\n\(e.localizedFailureReason ?? "")\n\(e.localizedRecoverySuggestion ?? "")\n\(e.localizedDescription)"
                errorHandler(errormsg, nil)
                return
            }
            
            if let r = response {
                if r.statusCode.isSuccess() {
                    success()
                } else if r.statusCode == 400 {
                    errorHandler(nil, RegistrationErrorInfo(json: json))
                }
            }
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
