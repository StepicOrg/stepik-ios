//
//  ApplicationInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.03.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

enum AuthType: String {
    case social = "social", password = "password"
}

class ApplicationInfo {
    var clientId : String = ""
    var clientSecret: String = ""
    var redirectUri : String = ""

    var credentials : String {
        let credentialData = "\(clientId):\(clientSecret)".data(using: String.Encoding.utf8)!
        return credentialData.base64EncodedString(options: [])
    }
    
    init(clientId id: String, clientSecret secret: String, redirectUri uri: String) {
        self.clientId = id
        self.clientSecret = secret
        self.redirectUri = uri
    }
    
    convenience init?(plist: String, type: AuthType) {
        let bundle = Bundle(for: type(of: self) as AnyClass)
        guard let path = bundle.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        guard let dic = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return nil
        }
        guard let authDic = dic[type.rawValue] as? [String: String] else {
            return nil
        }
        guard let id = authDic["id"], let secret = authDic["secret"], let redirect = authDic["redirect_uri"] else {
            return nil
        }
        self.init(clientId: id, clientSecret: secret, redirectUri: redirect)
    }

}
