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
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies ?? [] {
            if cookie.domain.range(of: "stepic") != nil || cookie.domain.range(of: "stepik") != nil {
                storage.deleteCookie(cookie)
            }
        }
        cookieDict = [:]
        cookieHeaders = [:]
    }
    
    static func refresh(completion: @escaping ((Void) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {
        print("refreshing session")
        let stepicURLString = StepicApplicationsInfo.stepicURL
        let stepicURL = URL(string: stepicURLString)!
        delete()
        
        return Alamofire.request(stepicURLString, parameters: nil, encoding: URLEncoding.default).response { 
            response in
            
            let error = response.error
            let response = response.response
            
            
            if let e = error {
                errorHandler((e as NSError).localizedDescription)
            }
            
            if let r = response {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: r.allHeaderFields as! [String: String], for: stepicURL)
                HTTPCookieStorage.shared.setCookies(cookies, for: stepicURL, mainDocumentURL: nil)
                
                var cookieDict = [String: String]()
                for cookie in cookies {
                    cookieDict[cookie.name] = cookie.value
                }
                
                print(cookieDict)
                
                Session.cookieDict = cookieDict
                
                if let csrftoken = cookieDict["\(StepicApplicationsInfo.cookiePrefix)csrftoken"],
                    let sessionId = cookieDict["\(StepicApplicationsInfo.cookiePrefix)sessionid"] {
                    
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
