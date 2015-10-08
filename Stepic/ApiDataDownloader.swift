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
//            print("token -> \(t.accessToken)")
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
//            print(json["courses"])
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
//            print(t.accessToken)
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
    
    func getUsersByIds(ids: [Int], deleteUsers : [User], success : (([User]) -> Void)?, failure : (error : ErrorType) -> Void) {
        
        let headers : [String : String] = [:] 
        
        var params : [String : NSObject] = [:]
        params["access_token"] = StepicAPI.shared.token?.accessToken
        
        let userString = constructIdsString(array: ids)
        if userString == "" {
            success?([])
            return
        }
        
        Alamofire.request(.GET, "https://stepic.org/api/users?" + userString, parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            // print(json["users"])
            
            for user in deleteUsers {
                CoreDataHelper.instance.context.deleteObject(user)
            }
            CoreDataHelper.instance.save()
            
            var newUsers : [User] = []
            for userJSON in json["users"].arrayValue {
                newUsers += [User(json: userJSON)]
            }
            
            success?(newUsers) 

        })
    }
    
    private func constructIdsString(array arr: [Int]) -> String {
        var result = ""
        for element in arr {
            result += "ids[]=\(element)&"
        }
        if result != "" { 
            result.removeAtIndex(result.endIndex.predecessor()) 
        }
        return result
    }
    
        
    func getSectionsByIds(ids: [Int], existingSections : [Section], success : (([Section]) -> Void)?, failure : (error : ErrorType) -> Void) {
        let headers : [String : String] = [:]
        var params : [String : NSObject] = [:]
        
        params["access_token"] = StepicAPI.shared.token?.accessToken
        
        let sectionString = constructIdsString(array: ids)
        if sectionString == "" {
            success?([])
            return
        }
        
        Alamofire.request(.GET, "https://stepic.org/api/sections?" + sectionString, parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            
//            print(json["sections"])
//            print("existing sections count -> \(existingSections.count)")
            for section in existingSections {
                CoreDataHelper.instance.context.deleteObject(section)
            }
            CoreDataHelper.instance.save()
            
            var newSections : [Section] = []
            for sectionJSON in json["sections"].arrayValue {
                newSections += [Section(json: sectionJSON)]
            }
            
            success?(newSections) 
            
            
        })
        
    }
    

    
    
}
