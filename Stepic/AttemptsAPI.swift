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
import PromiseKit

class AttemptsAPI: APIEndpoint {
    override var name: String { return "attempts" }

    func create(stepName: String, stepId: Int) -> Promise<Attempt> {
        let attempt = Attempt(step: stepId)
        return Promise { fulfill, reject in
            create.request(requestEndpoint: "attempts", paramName: "attempt", creatingObject: attempt, withManager: manager).then {
                attempt, json -> Void in
                guard let json = json else {
                    fulfill(attempt)
                    return
                }
                attempt.initDataset(json: json["attempts"].arrayValue[0]["dataset"], stepName: stepName)
                fulfill(attempt)
            }.catch {
                error in
                reject(error)
            }
        }
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

        return manager.request("\(StepicApplicationsInfo.apiURL)/attempts", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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

extension AttemptsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func create(stepName: String, stepId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Attempt) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        create(stepName: stepName, stepId: stepId).then {
            attempt in
            success(attempt)
        }.catch {
            error in
            errorHandler(error.localizedDescription)
        }
        return nil
    }
}
