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
    
    
    func getDisplayedCoursesIds(featured featured: Bool?, enrolled: Bool?, page: Int?, success : ([Int], Meta) -> Void, failure : (error : ErrorType) -> Void) {
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

        params["access_token"] = StepicAPI.shared.token?.accessToken
        
        Alamofire.request(.GET, "https://stepic.org/api/courses", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            //TODO: Remove from here 
            if let e = error {
                print(e)
                failure(error: e)
                return
            }
            
            let meta = Meta(json: json["meta"])
            var res : [Int] = []
            
            for objectJSON in json["courses"].arrayValue {
                res += [objectJSON["id"].intValue]
            }
            success(res, meta)
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
            
            //TODO: Delete from here
            if let e = error {
                print(e)
                failure(error: e)
                return
            }
            
//            print(json["users"])
            
            let user : User = User(json: json["users"].arrayValue[0])
            success(user)
        })
    }
    
    private func constructIdsString<TID>(array arr: [TID]) -> String {
        var result = ""
        for element in arr {
            result += "ids[]=\(element)&"
        }
        if result != "" { 
            result.removeAtIndex(result.endIndex.predecessor()) 
        }
        return result
    }

    
    func getUsersByIds(ids: [Int], deleteUsers : [User], refreshMode: RefreshMode, success : (([User]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "users", ids: ids, deleteObjects: deleteUsers, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getSectionsByIds(ids: [Int], existingSections : [Section], refreshMode: RefreshMode, success : (([Section]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "sections", ids: ids, deleteObjects: existingSections, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getUnitsByIds(ids: [Int], deleteUnits : [Unit], refreshMode: RefreshMode, success : (([Unit]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "units", ids: ids, deleteObjects: deleteUnits, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getLessonsByIds(ids: [Int], deleteLessons : [Lesson], refreshMode: RefreshMode, success : (([Lesson]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "lessons", ids: ids, deleteObjects: deleteLessons, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getStepsByIds(ids: [Int], deleteSteps : [Step], refreshMode: RefreshMode, success : (([Step]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "steps", ids: ids, deleteObjects: deleteSteps, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getCoursesByIds(ids: [Int], deleteCourses : [Course], refreshMode: RefreshMode, success : (([Course]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "courses", ids: ids, deleteObjects: deleteCourses, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getAssignmentsByIds(ids: [Int], deleteAssignments : [Assignment], refreshMode: RefreshMode, success : (([Assignment]) -> Void)?, failure : (error : ErrorType) -> Void) {
        getObjectsByIds(requestString: "assignments", ids: ids, deleteObjects: deleteAssignments, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    private func getObjectsByIds<T : JSONInitializable>(requestString requestString: String, printOutput: Bool = false, ids: [Int], deleteObjects : [T], refreshMode: RefreshMode, success : (([T]) -> Void)?, failure : (error : ErrorType) -> Void) {
        
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
            
            if printOutput { 
                print(json)
            }
            
            if let e = error {
                failure(error: e)
                return
            }
            
            var newObjects : [T] = []
            
            switch refreshMode {
                
            case .Delete:
                
                for object in deleteObjects {
                    CoreDataHelper.instance.deleteFromStore(object as! NSManagedObject, save: false)
                }
                
                for objectJSON in json[requestString].arrayValue {
                    newObjects += [T(json: objectJSON)]
                }
                                
            case .Update:
                
                for objectJSON in json[requestString].arrayValue {
                    let existing = deleteObjects.filter({obj in obj.id == objectJSON["id"].intValue})
                    
                    switch existing.count {
                    case 0: 
                        newObjects += [T(json: objectJSON)]
                    case 1: 
                        let obj = existing[0] 
                        obj.update(json: objectJSON)
                        newObjects += [obj]
                    default:
                        print("More than 1 object with the same id!")
                    }
                }
            }
            
            CoreDataHelper.instance.save()
            success?(newObjects)
             
        })
    }
    
    func getProgressesByIds(ids: [String], deleteProgresses : [Progress], refreshMode: RefreshMode, success : (([Progress]) -> Void)?, failure : (error : ErrorType) -> Void) {
        let requestString = "progresses"
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
            
//            print(json)
            
            if let e = error {
                failure(error: e)
                return
            }
            
            var newObjects : [Progress] = []
            
            switch refreshMode {
                
            case .Delete:
                
                for object in deleteProgresses {
                    CoreDataHelper.instance.deleteFromStore(object, save: false)
                }
                
                for objectJSON in json[requestString].arrayValue {
                    newObjects += [Progress(json: objectJSON)]
                }
                
            case .Update:
                
                for objectJSON in json[requestString].arrayValue {
                    let existing = deleteProgresses.filter({obj in obj.id == objectJSON["id"].stringValue})
                    
                    switch existing.count {
                    case 0: 
                        newObjects += [Progress(json: objectJSON)]
                    case 1: 
                        let obj = existing[0] 
                        obj.update(json: objectJSON)
                        newObjects += [obj]
                    default:
                        print("More than 1 object with the same id!")
                    }
                }
            }
            
            CoreDataHelper.instance.save()
            success?(newObjects)
            
        })
    }
    
    func didVisitStepWith(id id: Int, assignment: Int, success: Void->Void) {
        let headers : [String : String] = [
            "Content-Type" : "application/json",
            "Authorization" : "Bearer \(StepicAPI.shared.token!.accessToken)"
        ]
        
//        print("{view:{step:\"\(id)\", assignment:\"\(assignment)\"}}")
        
        let params : [String : AnyObject] = [
            "view" : [
                "step" : "\(id)", 
                "assignment" : "\(assignment)"
            ]
        ]
        
        //        params["access_token"] = StepicAPI.shared.token!.accessToken
        
        Alamofire.request(.POST, "https://stepic.org/api/views", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON(completionHandler: {
            (_, _, json, error) in
            
            if let _ = error {
                return
            }
            
//            print(json)
            success()
        })
    }
    
    func search(query query: String, type: String?, page: Int?, success: ([SearchResult], Meta) -> Void, error errorHandler: String->Void) {
        let headers : [String : String] = [:]
        var params : [String : NSObject] = [:]
        
        params["access_token"] = StepicAPI.shared.token?.accessToken
        params["query"] = query
        
        if let p = page { 
            params["page"] = p 
        }
        if let t = type {
            params["type"] = t
        }
        
        Alamofire.request(.GET, "https://stepic.org/api/search-results", parameters: params, encoding: .URL, headers: headers).responseSwiftyJSON(completionHandler: { 
            _, _, json, error in
            
            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }
            
//            print("search results for query -> \(query)\n\(json)")
            
            let meta = Meta(json: json["meta"])
            var results = [SearchResult]() 
            for resultJson in json["search-results"].arrayValue {
                results += [SearchResult(json: resultJson)]
            }
            
            success(results, meta)
        })
    }
    
}



enum RefreshMode {
    case Delete, Update
}