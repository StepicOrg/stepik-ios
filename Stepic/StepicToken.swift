//
//  StepicToken.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class StepicToken: DictionarySerializable {
    let accessToken : String!
    let refreshToken : String!
    let tokenType : String!
    let expireDate: Date!
    
    //delta used to have a gap when token expires
    let expireDelta = TimeInterval(1000)
    
    init(json: JSON) {
        accessToken = json["access_token"].stringValue
        refreshToken = json["refresh_token"].stringValue
        tokenType = json["token_type"].stringValue
        expireDate = Date().addingTimeInterval(json["expires_in"].doubleValue - expireDelta)
    }
    
    init(accessToken: String, refreshToken: String, tokenType: String, expireDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expireDate = expireDate
    }
    
    required convenience init?(dictionary: [String : AnyObject]) {
        if let aToken = dictionary["access_token"] as? String,
            let rToken = dictionary["refresh_token"] as? String, 
            let tType = dictionary["token_type"] as? String {
            self.init(accessToken: aToken, refreshToken: rToken, tokenType: tType, expireDate: Date(timeIntervalSince1970: dictionary["expire_date"] as? TimeInterval ?? 0.0))
        } else {
            return nil
        }
    }
    
    func serializeToDictionary() -> [String : AnyObject] {
        return getDictionary()
    }
    
    func getDictionary() -> [String: AnyObject] {
        var res = [String: AnyObject]()
        res["access_token"] = accessToken as AnyObject?
        res["refresh_token"] = refreshToken as AnyObject?
        res["token_type"] = tokenType as AnyObject?
        res["expire_date"] = expireDate.timeIntervalSince1970 as AnyObject?
        return res
    }
}
