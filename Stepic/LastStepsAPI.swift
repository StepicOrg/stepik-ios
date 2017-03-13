//
//  LastStepsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class LastStepsAPI {
    let name = "last-steps"
    
    func retrieve(id: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((LastStep?) -> Void), error errorHandler: @escaping ((LastStepsRetrieveError) -> Void)) -> Request {
        
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
                    print("RETRIEVE last-steps?\(id): error \(e.domain) \(e.code): \(e.localizedDescription)")
                    errorHandler(.connectionError)
                    return
                }
                
                if response?.statusCode != 200 {
                    print("RETRIEVE last-steps?\(id)): bad response status code \(response?.statusCode)")
                    errorHandler(.badStatus)
                    return
                }
                
                let lastSteps = json["last-steps"].arrayValue.map({return LastStep(json: $0)})
                
                success(lastSteps.first)
                return
            }
        )
    }
}

enum LastStepsRetrieveError : Error {
    case connectionError, badStatus
}
