//
//  StepicsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON 

class StepicsAPI {
    
    let manager : Alamofire.Manager
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 5
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    func retrieveCurrentUser(headers: [String: String] = APIDefaults.headers.bearer, success: User -> Void, error errorHandler: String -> Void) -> Request {
        let params = [String:AnyObject]()
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/stepics/1", parameters: params, headers: headers, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error as? NSError {
                print(e.localizedDescription)
                
                errorHandler(e.localizedDescription)
                return
            }
                        
            let user : User = User(json: json["users"].arrayValue[0])
            success(user)
        })

    }
}