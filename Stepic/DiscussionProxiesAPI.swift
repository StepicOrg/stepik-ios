//
//  DiscussionProxiesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class DiscussionProxiesAPI {
    let name = "discussion-proxies"
    
    func retrieve(id: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: (DiscussionProxy -> Void), error errorHandler: (String -> Void)) -> Request {
        return Alamofire.request(.GET, "\(StepicApplicationsInfo.apiURL)/\(name)/\(id)", headers: headers).responseSwiftyJSON(
            {
                _, response, json, error in 
                
                if let e = error as? NSError {
                    errorHandler("RETRIEVE discussion-proxies/\(id): error \(e.domain) \(e.code): \(e.localizedDescription)")
                    return
                }
                
                if response?.statusCode != 200 {
                    errorHandler("RETRIEVE discussion-proxies/\(id): bad response status code \(response?.statusCode)")
                    return
                }

                let discussionProxy = DiscussionProxy(json: json["discussion-proxies"].arrayValue[0])
                success(discussionProxy)
                
                return
            }
        )
    }
}