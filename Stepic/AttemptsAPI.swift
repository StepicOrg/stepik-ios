//
//  AttemptsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class AttemptsAPI: APIEndpoint {
    override var name: String { "attempts" }

    /// Get attempts by ids.
    func retrieve(
        ids: [Attempt.IdType],
        stepName: String,
        page: Int = 1,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders
    ) -> Promise<([Attempt], Meta)> {
        let parameters: Parameters = [
            "ids": ids,
            "page": page
        ]

        return Promise { seal in
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
                    let attempts = json["attempts"].arrayValue.map { Attempt(json: $0, stepBlockName: stepName) }
                    seal.fulfill((attempts, meta))
                }
            }
        }
    }

    func create(stepName: String, stepID: Int) -> Promise<Attempt> {
        let attempt = Attempt(stepID: stepID)
        return Promise { seal in
            self.create.request(
                requestEndpoint: "attempts",
                paramName: "attempt",
                creatingObject: attempt,
                withManager: manager
            ).done { attempt, json in
                attempt.initDataset(json: json["attempts"].arrayValue[0]["dataset"], stepBlockName: stepName)
                seal.fulfill(attempt)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieve(stepName: String, stepID: Int, userID: Int) -> Promise<([Attempt], Meta)> {
        Promise { seal in
            self.retrieve(
                stepName: stepName,
                stepID: stepID,
                userID: userID,
                success: { attempts, meta in
                    seal.fulfill((attempts, meta))
                },
                error: {
                    seal.reject(NSError(domain: $0, code: -1, userInfo: nil))
                }
            )
        }
    }

    @discardableResult
    func retrieve(
        stepName: String,
        stepID: Int,
        userID: Int,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ([Attempt], Meta) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
        let headers = AuthInfo.shared.initialHTTPHeaders

        var params: Parameters = [:]
        params["step"] = stepID
        params["user"] = userID

        return self.manager.request(
            "\(StepikApplicationsInfo.apiURL)/attempts",
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

            if let error = error {
                let description = (error as NSError).localizedDescription
                print(description)
                errorHandler(description)
                return
            }

            if response?.statusCode == 200 {
                let meta = Meta(json: json["meta"])
                let attempts = json["attempts"].arrayValue.map({ Attempt(json: $0, stepBlockName: stepName) })
                success(attempts, meta)
                return
            } else {
                errorHandler("Response status code is wrong(\(String(describing: response?.statusCode)))")
                return
            }
        }
    }
}

extension AttemptsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func create(
        stepName: String,
        stepID: Int,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping (Attempt) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
        self.create(stepName: stepName, stepID: stepID).done { attempt in
            success(attempt)
        }.catch { error in
            errorHandler(error.localizedDescription)
        }
        return nil
    }
}
