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
    @discardableResult func signUpWith(socialToken: String, email: String?, provider: String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error: SignInError) -> Void) -> Request? {
        var params: Parameters = [
            "provider": provider,
            "code": socialToken,
            "grant_type": "authorization_code",
            "redirect_uri": "\(StepicApplicationsInfo.social!.redirectUri)",
            "code_type": "access_token"
        ]

        if email != nil {
            params["email"] = email!
        }

        let headers = [
            "Authorization": "Basic \(StepicApplicationsInfo.social!.credentials)"
        ]

        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/social-token/", method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON {
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if let e = error {
                failure(SignInError.other(error: e, code: nil, message: nil))
                return
            }

            if json["error"] != JSON.null {
                switch json["error"].stringValue {
                case "social_signup_with_existing_email":
                    failure(SignInError.existingEmail(provider: json["provider"].string, email: json["email"].string))
                default:
                    failure(SignInError.other(error: nil, code: response?.statusCode, message: json["error"].string))
                }
                return
            }

            let token: StepicToken = StepicToken(json: json)
            AuthInfo.shared.authorizationType = AuthorizationType.code
            success(token)
        }
    }
}
