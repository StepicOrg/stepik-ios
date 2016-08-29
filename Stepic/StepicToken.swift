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
    let expireDate: NSDate!
    
    //delta used to have a gap when token expires
    let expireDelta = NSTimeInterval(1000)
    
    init(json: JSON) {
        accessToken = json["access_token"].stringValue
        refreshToken = json["refresh_token"].stringValue
        tokenType = json["token_type"].stringValue
        expireDate = NSDate().dateByAddingTimeInterval(json["expires_in"].doubleValue - expireDelta)
    }
    
    init(accessToken: String, refreshToken: String, tokenType: String, expireDate: NSDate) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expireDate = expireDate
    }
    
    required convenience init?(dictionary: [String : AnyObject]) {
        if let aToken = dictionary["access_token"] as? String,
            rToken = dictionary["refresh_token"] as? String, 
            tType = dictionary["token_type"] as? String {
            self.init(accessToken: aToken, refreshToken: rToken, tokenType: tType, expireDate: NSDate(timeIntervalSince1970: dictionary["expire_date"] as? NSTimeInterval ?? 0.0))
        } else {
            return nil
        }
    }
    
    func serializeToDictionary() -> [String : AnyObject] {
        return getDictionary()
    }
    
    func getDictionary() -> [String: AnyObject] {
        var res = [String: AnyObject]()
        res["access_token"] = accessToken
        res["refresh_token"] = refreshToken
        res["token_type"] = tokenType
        res["expire_date"] = expireDate.timeIntervalSince1970
        return res
    }
}