//
//  SubmissionsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class SubmissionsAPI: APIEndpoint {
    override var name: String { "submissions" }

    @discardableResult
    private func retrieve(
        stepName: String,
        objectName: String,
        objectId: Int,
        isDescending: Bool? = true,
        page: Int? = 1,
        userId: Int? = nil,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ([Submission], Meta) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
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

        return manager.request(
            "\(StepikApplicationsInfo.apiURL)/submissions",
            method: .get,
            parameters: params,
            encoding: URLEncoding.default,
            headers: headers
        ).responseSwiftyJSON { response in
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
                let submissions = json["submissions"].arrayValue.map({ Submission(json: $0, stepBlockName: stepName) })
                success(submissions, meta)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        }
    }
    
    /// Get user submissions for the step.
    func retrieve(
        stepID: Int,
        stepName: String,
        userID: User.IdType,
        page: Int = 1,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<([Submission], Meta)> {
        Promise { seal in
            let parameters: Parameters = [
                "order": "desc",
                "page": page,
                "step": stepID,
                "user": userID
            ]
            
            self.manager.request(
                "\(StepikApplicationsInfo.apiURL)/\(self.name)",
                method: .get,
                parameters: parameters,
                encoding: URLEncoding.default,
                headers: headers
            ).validate().responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    let meta = Meta(json: json["meta"])
                    let submissions = json["submissions"].arrayValue.map { Submission(json: $0, stepBlockName: stepName) }
                    seal.fulfill((submissions, meta))
                }
            }
        }
    }

    @discardableResult
    func retrieve(
        stepName: String,
        attemptId: Int,
        isDescending: Bool? = true,
        page: Int? = 1,
        userId: Int? = nil,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ([Submission], Meta) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
        self.retrieve(
            stepName: stepName,
            objectName: "attempt",
            objectId: attemptId,
            isDescending: isDescending,
            page: page,
            userId: userId,
            headers: headers,
            success: success,
            error: errorHandler
        )
    }

    @discardableResult
    func retrieve(
        stepName: String,
        stepId: Int,
        isDescending: Bool? = true,
        page: Int? = 1,
        userId: Int? = nil,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ([Submission], Meta) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
        self.retrieve(
            stepName: stepName,
            objectName: "step",
            objectId: stepId,
            isDescending: isDescending,
            page: page,
            userId: userId,
            headers: headers,
            success: success,
            error: errorHandler
        )
    }

    func retrieve(stepName: String, submissionId: Int) -> Promise<Submission> {
        Promise { seal in
            self.retrieve(stepName: stepName, submissionId: submissionId, success: { submission in
                seal.fulfill(submission)
            }, error: { error in
                seal.reject(NSError(domain: error, code: -1, userInfo: nil))
            })
        }
    }

    func retrieve(stepName: String, attemptID: Int) -> Promise<([Submission], Meta)> {
        Promise { seal in
            self.retrieve(stepName: stepName, attemptId: attemptID, success: { submissions, meta in
                seal.fulfill((submissions, meta))
            }, error: { error in
                seal.reject(NSError(domain: error, code: -1, userInfo: nil))
            })
        }
    }

    func retrieve(stepName: String, stepID: Int, page: Int = 1) -> Promise<([Submission], Meta)> {
        Promise { seal in
            self.retrieve(stepName: stepName, stepId: stepID, page: page, success: { submissions, meta in
                seal.fulfill((submissions, meta))
            }, error: { error in
                seal.reject(NSError(domain: error, code: -1, userInfo: nil))
            })
        }
    }
    
    @discardableResult
    func retrieve(
        stepName: String,
        submissionId: Int,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping (Submission) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
        let params: Parameters = [:]

        return self.manager.request(
            "\(StepikApplicationsInfo.apiURL)/submissions/\(submissionId)",
            parameters: params,
            encoding: URLEncoding.default,
            headers: headers
        ).responseSwiftyJSON({ response in
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
                let submission = Submission(json: json["submissions"][0], stepBlockName: stepName)
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
        return Promise { seal in
            self.create.request(
                requestEndpoint: "submissions",
                paramName: "submission",
                creatingObject: submission,
                withManager: manager
            ).done { submission, json in
                submission.initReply(json: json["submissions"].arrayValue[0]["reply"], stepBlockName: stepName)
                seal.fulfill(submission)
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }
}

extension SubmissionsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func create(
        stepName: String,
        attemptId: Int,
        reply: Reply,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping (Submission) -> Void,
        error errorHandler: @escaping (Error) -> Void
    ) -> Request? {
        self.create(stepName: stepName, attemptId: attemptId, reply: reply).done { submission in
            success(submission)
        }.catch { error in
            errorHandler(error)
        }
        return nil
    }
}