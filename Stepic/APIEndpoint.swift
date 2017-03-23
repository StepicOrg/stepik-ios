//
//  APIEndpoint.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class APIEndpoint {
    
    func constructIdsString<TID>(array arr: [TID]) -> String {
        var result = ""
        for element in arr {
            result += "ids[]=\(element)&"
        }
        if result != "" { 
            result.remove(at: result.characters.index(before: result.endIndex)) 
        }
        return result
    }

    
    func getObjectsByIds<T : JSONInitializable>(requestString: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, printOutput: Bool = false, ids: [T.idType], deleteObjects : [T], refreshMode: RefreshMode, success : (([T]) -> Void)?, failure : @escaping (_ error : RetrieveError) -> Void) -> Request? {
        
        let params : Parameters = [:]
        
        let idString = constructIdsString(array: ids)
        if idString == "" {
            success?([])
            return nil
        }
        
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(requestString)?\(idString)", parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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

            if printOutput { 
                print(json)
            }
            
            print(json)
            
            if let e = error as? NSError {
                print("RETRIEVE \(requestString)?\(ids): error \(e.domain) \(e.code): \(e.localizedDescription)")
                failure(.connectionError)
                return
            }
            
            if response?.statusCode != 200 {
                print("RETRIEVE \(requestString)?\(ids)): bad response status code \(response?.statusCode)")
                failure(.badStatus)
                return
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
                    let existing = deleteObjects.filter({obj in obj.hasEqualId(json: objectJSON)})
                    
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
}
