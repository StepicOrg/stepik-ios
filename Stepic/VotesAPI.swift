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

    func update(vote: Vote, headers: [String: String] = APIDefaults.headers.bearer, success: (Vote->Void), error errorHandler: (String->Void)) {
        let params : [String: AnyObject]? = [
            "vote" : vote.json
        ]
        Alamofire.request(.PUT, "https://stepic.org/api/votes/\(vote.id)", parameters: params, encoding: .JSON, headers: headers).responseSwiftyJSON(
            {
                _, response, json, error in
                
                print(json)
                
                if let e = error as? NSError {
                    errorHandler("PUT vote: error \(e.domain) \(e.code): \(e.localizedDescription)")
                    return
                }
                
                if response?.statusCode != 200 {
                    errorHandler("PUT vote: bad response status code \(response?.statusCode)")
                    return
                }
                
                let retrievedVote = Vote(json: json["votes"].arrayValue[0])
                success(retrievedVote)
                
                return
            }
        )
    }
}