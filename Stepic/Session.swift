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
        cookies = []
    }
    
    static func refresh(completion completion: ([NSHTTPCookie] -> Void), error errorHandler: (String -> Void)) -> Request? {
        let stepicURLString = "\(StepicApplicationsInfo.stepicURL)/accounts/signup/?next=/"
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
                
                Session.cookies = cookies
                completion(cookies)
                
                errorHandler("No cookie for csrftoken")
            } else {
                errorHandler("No response")
            }
        }
    }
    
    static var hasCookies : Bool {
        return cookies.count > 0
    }
    
    static var cookies = [NSHTTPCookie]()
    
    static var cookiesDict : [String: String] {
        var res = [String: String]()
        for cookie in cookies {
            res[cookie.name] = cookie.value
        }
        return res
    }
}