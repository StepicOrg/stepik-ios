//
//  Session.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire 


class Session {
    
    static func delete() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies ?? [] {
            if cookie.domain.rangeOfString("stepic") != nil || cookie.domain.rangeOfString("stepik") != nil {
                storage.deleteCookie(cookie)
            }
        }
        cookieDict = [:]
        cookieHeaders = [:]
    }
    
    static func refresh(completion completion: (Void -> Void), error errorHandler: (String -> Void)) -> Request? {
        let stepicURLString = StepicApplicationsInfo.stepicURL
        let stepicURL = NSURL(string: stepicURLString)!
        delete()
        
        return Alamofire.request(.GET, stepicURLString, parameters: nil, encoding: .URL).response { 
            (request, response, _, error) -> Void in
            
            if let e = error {
                errorHandler((e as NSError).localizedDescription)
            }
            
            if let r = response {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(r.allHeaderFields as! [String: String], forURL: stepicURL)
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: stepicURL, mainDocumentURL: nil)
                
                var cookieDict = [String: String]()
                for cookie in cookies {
                    cookieDict[cookie.name] = cookie.value
                }
                
                print(cookieDict)
                
                Session.cookieDict = cookieDict
                
                if let csrftoken = cookieDict["csrftoken"],
                    sessionId = cookieDict["sessionid"] {
                    
                    Session.cookieHeaders = [
                        "Referer" : "\(StepicApplicationsInfo.stepicURL)/",
                        "X-CSRFToken" : csrftoken,
                        "Cookie" : "csrftoken=\(csrftoken); sessionid=\(sessionId)"
                    ]
                    completion()
                } else {
                    errorHandler("bad cookies in response")
                }
            } else {
                errorHandler("No response")
            }
        }
    }
    
    static var needsRefresh : Bool {
        return cookieHeaders.count == 0
    }
    
    static var cookieHeaders = [String: String]()
    
    static var hasCookies : Bool {
        return cookieDict.count > 0
    }
        
    static var cookieDict = [String: String]()
}