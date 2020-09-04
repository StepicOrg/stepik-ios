//
//  StepicToken.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class StepikToken: DictionarySerializable {
    let accessToken: String!
    let refreshToken: String!
    let tokenType: String!
    let expireDate: Date!

    /// Delta used to have a gap when token expires.
    let expireDelta = TimeInterval(1000)

    init(json: JSON) {
        self.accessToken = json["access_token"].stringValue
        self.refreshToken = json["refresh_token"].stringValue
        self.tokenType = json["token_type"].stringValue
        self.expireDate = Date().addingTimeInterval(json["expires_in"].doubleValue - expireDelta)
    }

    init(accessToken: String, refreshToken: String, tokenType: String, expireDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expireDate = expireDate
    }

    required convenience init?(dictionary: [String: Any]) {
        guard let accessToken = dictionary["access_token"] as? String,
              let refreshToken = dictionary["refresh_token"] as? String,
              let tokenType = dictionary["token_type"] as? String else {
            return nil
        }

        self.init(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: tokenType,
            expireDate: Date(timeIntervalSince1970: dictionary["expire_date"] as? TimeInterval ?? 0.0)
        )
    }

    func serializeToDictionary() -> [String: Any] { self.getDictionary() }

    func getDictionary() -> [String: Any] {
        var res = [String: AnyObject]()
        res["access_token"] = accessToken as AnyObject?
        res["refresh_token"] = refreshToken as AnyObject?
        res["token_type"] = tokenType as AnyObject?
        res["expire_date"] = expireDate.timeIntervalSince1970 as AnyObject?
        return res
    }
}

extension StepikToken: CustomStringConvertible {
    var description: String {
        """
        StepikToken(accessToken: \(String(describing: self.accessToken)), \
        refreshToken: \(String(describing: self.refreshToken)), \
        tokenType: \(String(describing: self.tokenType)), \
        expireDate: \(String(describing: self.expireDate)), \
        expireDelta: \(self.expireDelta))
        """
    }
}
