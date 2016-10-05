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
    fileprivate override init() {}
    
    
    func getDisplayedCoursesIds(featured: Bool?, enrolled: Bool?, page: Int?, success : ([Int], Meta) -> Void, failure : (_ error : Error) -> Void) -> Request? {
        let headers : [String : String] = AuthInfo.shared.initialHTTPHeaders
        // = ["Authorization" : "\(AuthInfo.shared.token!.tokenType) \(AuthInfo.shared.token!.accessToken)"]
        
        var params : Parameters = [:]
        if let f = featured {
            params["is_featured"] = f ? "true" : "false"
        } 
        
        if let e = enrolled {
            params["enrolled"] = e ? "true" : "false"
        }
        
        if let p = page {
            params["page"] = p
        }

        params["access_token"] = AuthInfo.shared.token?.accessToken as NSObject?
        
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/courses", parameters: params, headers: headers, encoding: URLEncoding.default).responseSwiftyJSON({
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
    
    func getCurrentUser(_ success : @escaping (User) -> Void, failure : @escaping (_ error : Error) -> Void) {
        
        let headers : [String : String] = AuthInfo.shared.initialHTTPHeaders
        // = ["Authorization" : "\(AuthInfo.shared.token!.tokenType) \(AuthInfo.shared.token!.accessToken)"]
        
        var params : Parameters = [:]
               
        performRequest({
            params["access_token"] = AuthInfo.shared.token?.accessToken ?? ""
//            print(t.accessToken)
            self.getCurrentUserProfileApiCall(params, headers: headers, success: success, failure: failure)
            }, error: {
                _ in
                print("error while getting current user")
        })

    }
    
    fileprivate func getCurrentUserProfileApiCall(_ params: [String : NSObject], headers : [String : String] = AuthInfo.shared.initialHTTPHeaders, success : (User) -> Void, failure : (_ error : Error) -> Void) -> Request? {
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/stepics/1", parameters: params, headers: headers, encoding: .url).responseSwiftyJSON({
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
    
    fileprivate func constructIdsString<TID>(array arr: [TID]) -> String {
        var result = ""
        for element in arr {
            result += "ids[]=\(element)&"
        }
        if result != "" { 
            result.remove(at: result.characters.index(before: result.endIndex)) 
        }
        return result
    }

    
    func getUsersByIds(_ ids: [Int], deleteUsers : [User], refreshMode: RefreshMode, success : (([User]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        return getObjectsByIds(requestString: "users", headers: [String:String](), ids: ids, deleteObjects: deleteUsers, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getSectionsByIds(_ ids: [Int], existingSections : [Section], refreshMode: RefreshMode, success : (([Section]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        return getObjectsByIds(requestString: "sections", ids: ids, deleteObjects: existingSections, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getUnitsByIds(_ ids: [Int], deleteUnits : [Unit], refreshMode: RefreshMode, success : (([Unit]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        return getObjectsByIds(requestString: "units", ids: ids, deleteObjects: deleteUnits, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getLessonsByIds(_ ids: [Int], deleteLessons : [Lesson], refreshMode: RefreshMode, success : (([Lesson]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        return getObjectsByIds(requestString: "lessons", ids: ids, deleteObjects: deleteLessons, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getStepsByIds(_ ids: [Int], deleteSteps : [Step], refreshMode: RefreshMode, success : (([Step]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        return getObjectsByIds(requestString: "steps", ids: ids, deleteObjects: deleteSteps, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getCoursesByIds(_ ids: [Int], deleteCourses : [Course], refreshMode: RefreshMode, success : (([Course]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        return getObjectsByIds(requestString: "courses", ids: ids, deleteObjects: deleteCourses, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    func getAssignmentsByIds(_ ids: [Int], deleteAssignments : [Assignment], refreshMode: RefreshMode, success : (([Assignment]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        return getObjectsByIds(requestString: "assignments", ids: ids, deleteObjects: deleteAssignments, refreshMode: refreshMode, success: success, failure: failure)
    }
    
    fileprivate func getObjectsByIds<T : JSONInitializable>(requestString: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, printOutput: Bool = false, ids: [Int], deleteObjects : [T], refreshMode: RefreshMode, success : (([T]) -> Void)?, failure : @escaping (_ error : Error) -> Void) -> Request? {
        
        let params : [String : NSObject] = [:]
                
        let idString = constructIdsString(array: ids)
        if idString == "" {
            success?([])
            return nil
        }
        
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/\(requestString)?\(idString)", parameters: params, headers: headers, encoding: .url).responseSwiftyJSON({
            (_, response, json, error) in
            
            if printOutput { 
                print(json)
            }
            
            if let e = error {
                failure(error: e)
                return
            }
            
            if let r = response {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: r.allHeaderFields as! [String: String], for: URL(string: StepicApplicationsInfo.stepicURL)!)
                for cookie in cookies {
                    print("\(cookie.name) : \(cookie.value)")
                }
                //                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: NSURL(string: StepicApplicationsInfo.stepicURL)!, mainDocumentURL: NSURL(string: StepicApplicationsInfo.stepicURL)!)
            }
            
            
            var newObjects : [T] = []
            
            switch refreshMode {
                
            case .delete:
                
                for object in deleteObjects {
                    CoreDataHelper.instance.deleteFromStore(object as! NSManagedObject, save: false)
                }
                
                for objectJSON in json[requestString].arrayValue {
                    newObjects += [T(json: objectJSON)]
                }
                                
            case .update:
                
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
    
    func getProgressesByIds(_ ids: [String], deleteProgresses : [Progress], refreshMode: RefreshMode, success : (([Progress]) -> Void)?, failure : (_ error : Error) -> Void) -> Request? {
        let requestString = "progresses"
        let headers : [String : String] = AuthInfo.shared.initialHTTPHeaders
        var params : [String : NSObject] = [:]
        
        if ids.filter({$0 != ""}).count == 0 {
            failure(error: NSError(domain: NSCocoaErrorDomain, code: 500, userInfo: nil))
            return nil
        }
        
        params["access_token"] = AuthInfo.shared.token?.accessToken as NSObject?
        
        let idString = constructIdsString(array: ids)
        if idString == "" {
            success?([])
            return nil
        }
        
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/\(requestString)?\(idString)", parameters: params, headers: headers, encoding: .url).responseSwiftyJSON({
            (_, _, json, error) in
            
//            print(json)
            
            if let e = error {
                failure(error: e)
                return
            }
            
            var newObjects : [Progress] = []
            
            switch refreshMode {
                
            case .delete:
                
                for object in deleteProgresses {
                    CoreDataHelper.instance.deleteFromStore(object, save: false)
                }
                
                for objectJSON in json[requestString].arrayValue {
                    newObjects += [Progress(json: objectJSON)]
                }
                
            case .update:
                
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
    
    func didVisitStepWith(id: Int, assignment: Int?, success: (Void)->Void) -> Request? {
        let headers : [String : String] = AuthInfo.shared.initialHTTPHeaders
        
//        print("{view:{step:\"\(id)\", assignment:\"\(assignment)\"}}")
        var params : [String : AnyObject] = [:]
        
        if let assignment = assignment {
            params = [
                "view" : [
                    "step" : "\(id)", 
                    "assignment" : "\(assignment)"
                ]
            ]
        } else {
            params = [
                "view" : [
                    "step" : "\(id)", 
                    "assignment" : NSNull()
                ]
            ]
        }
                
        //        params["access_token"] = AuthInfo.shared.token!.accessToken
        
        return Alamofire.request(.POST, "\(StepicApplicationsInfo.apiURL)/views", parameters: params, encoding: .json, headers: headers).responseSwiftyJSON(completionHandler: {
            (_, _, json, error) in
            
            if let _ = error {
                return
            }
            
//            print(json)
            success()
        })
    }
    
    func search(query: String, type: String?, page: Int?, success: ([SearchResult], Meta) -> Void, error errorHandler: (String)->Void) -> Request? {
        let headers : [String : String] = AuthInfo.shared.initialHTTPHeaders
        var params : [String : NSObject] = [:]
        
        params["access_token"] = AuthInfo.shared.token?.accessToken as NSObject?
        params["query"] = query
        
        if let p = page { 
            params["page"] = p 
        }
        if let t = type {
            params["type"] = t
        }
        
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/search-results", parameters: params, encoding: .url, headers: headers).responseSwiftyJSON(completionHandler: { 
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
    
    
    func createNewAttemptWith(stepName: String, stepId: Int, success: (Attempt)->Void, error errorHandler: (String)->Void) -> Request? {
        
        let headers = AuthInfo.shared.initialHTTPHeaders
//        if let token = AuthInfo.shared.token {
//            headers = [
//                "Authorization" : "Bearer \(token.accessToken)"
//            ]
//        } else {
//            headers = Session.cookieHeaders
//        }
        
//        print("headers in createNewAttempt \(headers)")
        
        let params : [String : NSObject] = [
            "attempt": [
            "step" : "\(stepId)"
                ]
            ]
        
        return Alamofire.request(.POST, "\(StepicApplicationsInfo.apiURL)/attempts", parameters: params, encoding: .json, headers: headers).responseSwiftyJSON(completionHandler: {
            request, response, json, error in
            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }
            
            print("request headers: \(request.allHTTPHeaderFields)")
            
            if response?.statusCode == 201 {
//                print(json)
                let attempt = Attempt(json: json["attempts"].arrayValue[0], stepName: stepName) 
                success(attempt)
                return
            } else {
                errorHandler("Response status code is wrong(\(response?.statusCode))")
                return
            }
            
        })
    }
    
    func getAttemptsFor(stepName: String, stepId: Int, success: ([Attempt], Meta)->Void, error errorHandler: (String)->Void) -> Request? {

        let headers = AuthInfo.shared.initialHTTPHeaders
//        if let token = AuthInfo.shared.token {
//            headers = [
//                "Authorization" : "Bearer \(token.accessToken)"
//            ]
//        }
        
        var params : [String : NSObject] = [:]        
        params["step"] = stepId
        if let userid = AuthInfo.shared.userId {
            params["user"] = userid as NSObject?
        } else {
            print("no user id!")
        }
        
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/attempts", parameters: params, encoding: .url, headers: headers).responseSwiftyJSON(completionHandler: {
            _, response, json, error in
            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }
            
            if response?.statusCode == 200 {
//                print(json)
                let meta = Meta(json: json["meta"])
                let attempts = json["attempts"].arrayValue.map({return Attempt(json: $0, stepName: stepName)})
                success(attempts, meta)
                return
            } else {
                errorHandler("Response status code is wrong(\(response?.statusCode))")
                return
            }

        })
    }
    
    fileprivate func getSubmissionsWithObjectID(stepName: String, objectName: String, objectId: Int, isDescending: Bool? = true, page: Int? = 1, userId : Int? = nil, success: ([Submission], Meta)->Void, error errorHandler: (String)->Void) -> Request? {
        
        let headers = AuthInfo.shared.initialHTTPHeaders
//        if let token = AuthInfo.shared.token {
//            headers = [
//                "Authorization" : "Bearer \(token.accessToken)"
//            ]
//        }
        
        var params : [String : NSObject] = [:]
        
        params[objectName] = objectId
        if let desc = isDescending {
            params["order"] = desc ? "desc" : "asc"
        }
        if let p = page {
            params["page"] = p
        }
        if let user = userId {
            params["user"] = user
        }
        
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/submissions", parameters: params, encoding: .url, headers: headers).responseSwiftyJSON(completionHandler: { 
            _, response, json, error in
            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }
            
            if response?.statusCode == 200 {
                let meta = Meta(json: json["meta"])
                let submissions = json["submissions"].arrayValue.map({return Submission(json: $0, stepName: stepName)})
                success(submissions, meta)
                return
            } else {
                errorHandler("Response status code is wrong(\(response?.statusCode))")
                return
            }
        })
        
    }
    
    func getSubmissionsWith(stepName: String, attemptId: Int, isDescending: Bool? = true, page: Int? = 1, userId : Int? = nil, success: ([Submission], Meta)->Void, error errorHandler: (String)->Void) -> Request? {
        return getSubmissionsWithObjectID(stepName: stepName, objectName: "attempt", objectId: attemptId, isDescending: isDescending, page: page, userId: userId, success: success, error: errorHandler)
    }
    
    func getSubmissionsWith(stepName: String, stepId: Int, isDescending: Bool? = true, page: Int? = 1, userId : Int? = nil, success: ([Submission], Meta)->Void, error errorHandler: (String)->Void) -> Request? {
        return getSubmissionsWithObjectID(stepName: stepName, objectName: "step", objectId: stepId, isDescending: isDescending, page: page, userId: userId, success: success, error: errorHandler)
    }
    
    func createSubmissionFor(stepName: String, attemptId: Int, reply: Reply, success: (Submission)->Void, error errorHandler: (String)->Void) -> Request? {

        let headers = AuthInfo.shared.initialHTTPHeaders
//        if let token = AuthInfo.shared.token {
//            headers = [
//                "Authorization" : "Bearer \(token.accessToken)"
//            ]
//        }
        
        let params = [
            "submission": [
                "attempt" : "\(attemptId)",
                "reply" : reply.dictValue
            ]
        ]
        
        return Alamofire.request(.POST, "\(StepicApplicationsInfo.apiURL)/submissions", parameters: params, encoding: .json, headers: headers).responseSwiftyJSON(completionHandler: {
            _, response, json, error in
            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }
            
            if response?.statusCode == 201 {
                let submission = Submission(json: json["submissions"].arrayValue[0], stepName: stepName) 
                success(submission)
                return
            } else {
                errorHandler("Response status code is wrong(\(response?.statusCode))")
                return
            }
            
        })
    }    
    
    func getSubmissionFor(stepName: String, submissionId: Int, success: (Submission)->Void, error errorHandler: (String)->Void) -> Request? {
        
        var params : [String : NSObject] = [:]
        let headers = AuthInfo.shared.initialHTTPHeaders
        
//        if let token = AuthInfo.shared.token {
//            headers = [
//                "Authorization" : "Bearer \(token.accessToken)"
//            ]
//        }
        
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/submissions/\(submissionId)", parameters: params, encoding: .url, headers: headers).responseSwiftyJSON(completionHandler: { 
            _, response, json, error in
            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }
            
            if response?.statusCode == 200 {
                let submission = Submission(json: json["submissions"][0], stepName: stepName)
                success(submission)
                return
            } else {
                errorHandler("Response status code is wrong(\(response?.statusCode))")
                return
            }
        })
    }
    
    static let devices = DevicesAPI()
    static let discussionProxies = DiscussionProxiesAPI()
    static let comments = CommentsAPI()
    static let votes = VotesAPI()
    static let stepics = StepicsAPI()
    static let units = UnitsAPI()
}

enum RefreshMode {
    case delete, update
}
