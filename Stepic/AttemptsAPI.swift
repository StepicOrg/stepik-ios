//
//  AttemptsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AttemptsAPI: APIEndpoint {
    let name = "attempts"

    @discardableResult func create(stepName: String, stepId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Attempt) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        let params: Parameters = [
            "attempt": [
                "step": "\(stepId)"
            ]
        ]

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/attempts", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
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
            let request = response.request
            let response = response.response

            if let e = error {
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }

            print("request headers: \(String(describing: request?.allHTTPHeaderFields))")

            if response?.statusCode == 201 {
                let attempt = Attempt(json: json["attempts"].arrayValue[0], stepName: stepName)
                success(attempt)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }

        })
    }

    @discardableResult func retrieve(stepName: String, stepId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Attempt], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        let headers = AuthInfo.shared.initialHTTPHeaders

        var params: Parameters = [:]
        params["step"] = stepId
        if let userid = AuthInfo.shared.userId {
            params["user"] = userid as NSObject?
        } else {
            print("no user id!")
        }

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/attempts", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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
                let d = (e as NSError).localizedDescription
                print(d)
                errorHandler(d)
                return
            }

            if response?.statusCode == 200 {
                let meta = Meta(json: json["meta"])
                let attempts = json["attempts"].arrayValue.map({return Attempt(json: $0, stepName: stepName)})
                success(attempts, meta)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }

        })
    }
}
