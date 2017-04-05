//
//  ViewsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ViewsAPI : APIEndpoint {
    let name = "views"
    
    func create(stepId id: Int, assignment: Int?, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Void)->Void) -> Request? {
        var params : Parameters = [:]
        
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
                
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/views", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
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
            
            
            if let _ = error {
                return
            }
            
            success()
        })
    }

}
