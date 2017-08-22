//
//  SubmissionsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SubmissionsAPI: APIEndpoint {
    let name = "submissions"

    var url: String {
        return StepicApplicationsInfo.apiURL
    }

    @discardableResult fileprivate func retrieve(stepName: String, objectName: String, objectId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        var mutableParams = params
        mutableParams[objectName] = objectId
        if let desc = isDescending {
            mutableParams["order"] = desc ? "desc" : "asc"
        }
        if let p = page {
            mutableParams["page"] = p
        }
        if let user = userId {
            mutableParams["user"] = user
        }

        return Alamofire.request("\(url)/submissions", method: .get, parameters: mutableParams, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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
                let submissions = json["submissions"].arrayValue.map({return Submission(json: $0, stepName: stepName)})
                success(submissions, meta)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        })
    }

    @discardableResult func retrieve(stepName: String, attemptId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        return retrieve(stepName: stepName, objectName: "attempt", objectId: attemptId, isDescending: isDescending, page: page, userId: userId, params: params, headers: headers, success: success, error: errorHandler)
    }

    @discardableResult func retrieve(stepName: String, stepId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        return retrieve(stepName: stepName, objectName: "step", objectId: stepId, isDescending: isDescending, page: page, userId: userId, params: params, headers: headers, success: success, error: errorHandler)
    }

    @discardableResult func retrieve(stepName: String, submissionId: Int, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Submission) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        return Alamofire.request("\(url)/submissions/\(submissionId)", parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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
                let submission = Submission(json: json["submissions"][0], stepName: stepName)
                success(submission)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        })
    }

    @discardableResult func create(stepName: String, attemptId: Int, reply: Reply, params: Parameters = [:], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Submission) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        var mutableParams = params
        mutableParams["submission"] = [
            "attempt": "\(attemptId)",
            "reply": reply.dictValue
        ]

        return Alamofire.request("\(url)/submissions", method: .post, parameters: mutableParams, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
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

            if response?.statusCode == 201 {
                let submission = Submission(json: json["submissions"].arrayValue[0], stepName: stepName)
                success(submission)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        })
    }

}
