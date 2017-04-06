//
//  VotesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire 
import SwiftyJSON

class VotesAPI {

    @discardableResult func update(_ vote: Vote, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Vote)->Void), error errorHandler: @escaping ((String)->Void)) {
        let params : Parameters? = [
            "vote" : vote.json as AnyObject
        ]
        Alamofire.request("\(StepicApplicationsInfo.apiURL)/votes/\(vote.id)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON(
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
                
                                
                if let e = error as NSError? {
                    errorHandler("PUT vote: error \(e.domain) \(e.code): \(e.localizedDescription)")
                    return
                }
                
                if response?.statusCode != 200 {
                    errorHandler("PUT vote: bad response status code \(String(describing: response?.statusCode))")
                    return
                }
                
                let retrievedVote = Vote(json: json["votes"].arrayValue[0])
                success(retrievedVote)
                
                return
            }
        )
    }
}
