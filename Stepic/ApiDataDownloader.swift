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
import CoreData

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
    
        

    
    func getUsersByIds(ids: [Int], deleteUsers : [User], success : (([User]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "users", ids: ids, deleteObjects: deleteUsers, success: success, failure: failure)
    }
    
    func getSectionsByIds(ids: [Int], existingSections : [Section], success : (([Section]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "sections", ids: ids, deleteObjects: existingSections, success: success, failure: failure)
    }
    
    func getUnitsByIds(ids: [Int], deleteUnits : [Unit], success : (([Unit]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "units", ids: ids, deleteObjects: deleteUnits, success: success, failure: failure)
    }
    
    func getLessonsByIds(ids: [Int], deleteLessons : [Lesson], success : (([Lesson]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "lessons", ids: ids, deleteObjects: deleteLessons, success: success, failure: failure)
    }
    
    private func getObjectsByIds<T : JSONInitializable>(requestString requestString: String, ids: [Int], deleteObjects : [T], success : (([T]) -> Void)?, failure : (error : ErrorType) -> Void) {
        
        let headers : [String : String] = [:]
        var params : [String : NSObject] = [:]
        
        params["access_token"] = StepicAPI.shared.token?.accessToken
        
        let idString = constructIdsString(array: ids)
        if idString == "" {
            success?([])
            return
        }
        
        Alamofire.request(.GET, "https://stepic.org/api/\(requestString)?\(idString)", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            for object in deleteObjects {
                CoreDataHelper.instance.context.deleteObject(object as! NSManagedObject)
            }
            CoreDataHelper.instance.save()
            
            
            var newObjects : [T] = []
            for objectJSON in json[requestString].arrayValue {
                newObjects += [T(json: objectJSON)]
            }
            
            success?(newObjects) 
        })
    }
    
}