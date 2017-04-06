//
//  AuthAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AuthAPI {
    @discardableResult func signUpWith(socialToken: String, provider: String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error : Error) -> Void) -> Request? {
        let params: Parameters = [
            "provider": provider,
            "code": socialToken,
            "grant_type": "authorization_code",
            "redirect_uri": "\(StepicApplicationsInfo.social!.redirectUri)",
            "code_type": "access_token"
        ]
        
        let headers = [
            "Authorization" : "Basic \(StepicApplicationsInfo.social!.credentials)"
        ]
        
        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/social-token/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON {
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
            
            print("\(response?.statusCode)")
            print(json)

            if let e = error {
                failure(e)
                return
            }
            
            if json["error"] != nil {
                print(json["error_description"].stringValue)
                let e = NSError(domain: NSCocoaErrorDomain, code: 1488, userInfo: [NSLocalizedDescriptionKey : json["error_description"].stringValue])
                failure(e)
                return
            }
            
            let token : StepicToken = StepicToken(json: json)
            AuthInfo.shared.authorizationType = AuthorizationType.code
            success(token)
        }
    }
}
