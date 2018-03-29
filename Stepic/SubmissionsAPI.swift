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
import PromiseKit

class SubmissionsAPI: APIEndpoint {
    override var name: String { return "submissions" }

    @discardableResult fileprivate func retrieve(stepName: String, objectName: String, objectId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        var params: Parameters = [:]

        params[objectName] = objectId
        if let desc = isDescending {
            params["order"] = desc ? "desc" : "asc"
        }
        if let p = page {
            params["page"] = p
        }
        if let user = userId {
            params["user"] = user
        }

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/submissions", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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

    @discardableResult func retrieve(stepName: String, attemptId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        return retrieve(stepName: stepName, objectName: "attempt", objectId: attemptId, isDescending: isDescending, page: page, userId: userId, headers: headers, success: success, error: errorHandler)
    }

    @discardableResult func retrieve(stepName: String, stepId: Int, isDescending: Bool? = true, page: Int? = 1, userId: Int? = nil, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([Submission], Meta) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        return retrieve(stepName: stepName, objectName: "step", objectId: stepId, isDescending: isDescending, page: page, userId: userId, headers: headers, success: success, error: errorHandler)
    }

    @discardableResult func retrieve(stepName: String, submissionId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Submission) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {

        let params: Parameters = [:]

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/submissions/\(submissionId)", parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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

    func create(stepName: String, attemptId: Int, reply: Reply) -> Promise<Submission> {
        let submission = Submission(attempt: attemptId, reply: reply)
        return Promise { fulfill, reject in
            create.request(requestEndpoint: "submissions", paramName: "submission", creatingObject: submission, withManager: manager).then {
                submission, json -> Void in
                guard let json = json else {
                    fulfill(submission)
                    return
                }
                submission.initReply(json: json["submissions"].arrayValue[0]["reply"], stepName: stepName)
                fulfill(submission)
            }.catch {
                error in
                reject(error)
            }
        }
    }
}

extension SubmissionsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func create(stepName: String, attemptId: Int, reply: Reply, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (Submission) -> Void, error errorHandler: @escaping (String) -> Void) -> Request? {
        self.create(stepName: stepName, attemptId: attemptId, reply: reply).then {
            submission in
            success(submission)
        }.catch {
            error in
            errorHandler(error.localizedDescription)
        }
        return nil
    }

}
