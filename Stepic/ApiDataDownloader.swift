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
    
    func getCoursesWithFeatured(featured: Bool?, enrolled: Bool?, page: Int?, success : ([Course], Meta) -> Void, failure : (error : ErrorType) -> Void) {
        
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
            self.getCoursesApiCall(params, headers: headers, success: success, failure: failure)
            }, failure: {
                _ in
                print("error while refreshing the token")
        })
        
        
    }
    
    private func getCoursesApiCall(params: [String : NSObject], headers : [String : String], success : ([Course], Meta) -> Void, failure : (error : ErrorType) -> Void) {
        
        Alamofire.request(.GET, "https://stepic.org/api/courses", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            
            let meta = Meta(json: json["meta"])
//            print(json["courses"])
            var courses : [Course] = []
            for courseJSON in json["courses"].arrayValue {
                courses += [Course(json: courseJSON)]
            }
            success(courses, meta)
        })
    }
    
    func getCurrentUserProfile(success : (Profile) -> Void, failure : (error : ErrorType) -> Void) {
        
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
    
    private func getCurrentUserProfileApiCall(params: [String : NSObject], headers : [String : String], success : (Profile) -> Void, failure : (error : ErrorType) -> Void) {
        Alamofire.request(.GET, "https://stepic.org/api/stepics/1", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            // print(json)
            
            print(json["profiles"])
            let profile : Profile = Profile(json: json["profiles"].arrayValue[0])
            success(profile)
        })
    }
}
