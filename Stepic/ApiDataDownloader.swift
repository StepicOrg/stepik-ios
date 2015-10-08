//
//  ApiDataDownloader.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ApiDataDownloader: NSObject {
    
    static let sharedDownloader = ApiDataDownloader()
    private override init() {}
    
    func getCoursesWithFeatured(featured: Bool?, enrolled: Bool?, page: Int?, tabNumber: Int, success : ([Course], Meta) -> Void, failure : (error : ErrorType) -> Void) {
        
        let headers : [String : String] = [:] 
        // = ["Authorization" : "\(StepicAPI.shared.token!.tokenType) \(StepicAPI.shared.token!.accessToken)"]
        
        var params : [String : NSObject] = [:]
        if let f = featured {
            params["is_featured"] = f ? "true" : "false"
        } 
        
        if let e = enrolled {
            params["enrolled"] = e ? "true" : "false"
        }
        
        if let p = page {
            params["page"] = p
        }
        
        AuthentificationManager.sharedManager.refreshTokenWith(StepicAPI.shared.token!.refreshToken, success: {
            (t) in
            StepicAPI.shared.token = t
            params["access_token"] = t.accessToken
            print("token -> \(t.accessToken)")
            self.getCoursesApiCall(tabNumber, params: params, headers: headers, success: success, failure: failure)
            }, failure: {
                _ in
                print("error while refreshing the token")
        })
        
        
    }
    
    private func getCoursesApiCall(tabNumber: Int, params: [String : NSObject], headers : [String : String], success : ([Course], Meta) -> Void, failure : (error : ErrorType) -> Void) {
        
        Alamofire.request(.GET, "https://stepic.org/api/courses", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            
            let meta = Meta(json: json["meta"])
            print("--------------------------")
            print(json["courses"])
            var courses : [Course] = []
            
            
            //NOT AN OOP THING, FIX IT SOMEHOW IN THE FUTURE
            if meta.page == 1 {
                Course.deleteAll(tabNumber)
            }
            
            
            for courseJSON in json["courses"].arrayValue {
                courses += [Course(json: courseJSON, tabNumber: tabNumber)]
            }
            success(courses, meta)
        })
    }
    
    func getCurrentUser(success : (User) -> Void, failure : (error : ErrorType) -> Void) {
        
        let headers : [String : String] = [:] 
        // = ["Authorization" : "\(StepicAPI.shared.token!.tokenType) \(StepicAPI.shared.token!.accessToken)"]
        
        var params : [String : NSObject] = [:]
               
        AuthentificationManager.sharedManager.refreshTokenWith(StepicAPI.shared.token!.refreshToken, success: {
            (t) in
            StepicAPI.shared.token = t
            params["access_token"] = t.accessToken
            print(t.accessToken)
            self.getCurrentUserProfileApiCall(params, headers: headers, success: success, failure: failure)
            }, failure: {
                _ in
                print("error while refreshing the token")
        })

    }
    
    private func getCurrentUserProfileApiCall(params: [String : NSObject], headers : [String : String], success : (User) -> Void, failure : (error : ErrorType) -> Void) {
        Alamofire.request(.GET, "https://stepic.org/api/stepics/1", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            
//            print(json["users"])
            let user : User = User(json: json["users"].arrayValue[0])
            success(user)
        })
    }
    
    func getUserById(id: Int, refreshToken: Bool = true, success : (User) -> Void, failure : (error : ErrorType) -> Void) {
        let headers : [String : String] = [:] 
        // = ["Authorization" : "\(StepicAPI.shared.token!.tokenType) \(StepicAPI.shared.token!.accessToken)"]
        
        var params : [String : NSObject] = [:]
        
        if refreshToken {
            AuthentificationManager.sharedManager.refreshTokenWith(StepicAPI.shared.token!.refreshToken, success: {
                (t) in
                StepicAPI.shared.token = t
                params["access_token"] = t.accessToken
                print(t.accessToken)
                self.getUserByIdApiCall(id, params: params, headers: headers, success: success, failure: failure)
                }, failure: {
                    _ in
                    print("error while refreshing the token")
                })
        } else {
            params["access_token"] = StepicAPI.shared.token
            self.getUserByIdApiCall(id, params: params, headers: headers, success: success, failure: failure)
        }
    }
    
    private func getUserByIdApiCall(id: Int, params: [String : NSObject], headers : [String : String], success : (User) -> Void, failure : (error : ErrorType) -> Void) {
        Alamofire.request(.GET, "https://stepic.org/api/users/\(id)", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            
//            print(json["users"])
            let user : User = User(json: json["users"].arrayValue[0])
            success(user)
        })
    }
    
    
    func getSectionById(id: Int, existingSection: Section? = nil, refreshToken: Bool = true, success : ((Section) -> Void)?, failure : (error : ErrorType) -> Void) {
        let headers : [String : String] = [:] 
        // = ["Authorization" : "\(StepicAPI.shared.token!.tokenType) \(StepicAPI.shared.token!.accessToken)"]
        
        var params : [String : NSObject] = [:]
        
        if refreshToken {
            AuthentificationManager.sharedManager.refreshTokenWith(StepicAPI.shared.token!.refreshToken, success: {
                (t) in
                StepicAPI.shared.token = t
                params["access_token"] = t.accessToken
                print(t.accessToken)
                self.getSectionByIdApiCall(id, existingSection: existingSection, params: params, headers: headers, success: success, failure: failure)
                }, failure: {
                    _ in
                    print("error while refreshing the token")
            })
        } else {
            params["access_token"] = StepicAPI.shared.token
            self.getSectionByIdApiCall(id, existingSection: existingSection, params: params, headers: headers, success: success, failure: failure)
        }
    }
    
    private func getSectionByIdApiCall(id: Int, existingSection: Section? = nil, params: [String : NSObject], headers : [String : String], success : ((Section) -> Void)?, failure : (error : ErrorType) -> Void) {
        Alamofire.request(.GET, "https://stepic.org/api/sections/\(id)", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            
            //print(json["sections"])
            if let es = existingSection {
                es.initialize(json["sections"].arrayValue[0])
                if success != nil { success!(es) }
            } else {
                let section : Section = Section(json: json["sections"].arrayValue[0])
                if success != nil { success!(section) }
            }
            
        })
    }
    
    
}
