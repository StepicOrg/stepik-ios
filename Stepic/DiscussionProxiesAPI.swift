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
    
    func retrieve(_ id: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((DiscussionProxy) -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)/\(id)", headers: headers).responseSwiftyJSON(
            {
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
