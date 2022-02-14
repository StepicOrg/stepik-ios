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
    override class var name: String { "attempts" }

    /// Get attempts by ids.
    func retrieve(ids: [Attempt.IdType], stepName: String) -> Promise<[Attempt]> {
        self.retrieve.request(
            requestEndpoint: Self.name,
            ids: ids,
            withManager: self.manager
        ).then { json -> Promise<[Attempt]> in
            let attempts = json[Self.name].arrayValue.map { Attempt(json: $0, stepBlockName: stepName) }
            return .value(attempts)
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
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
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
        ).validate().responseSwiftyJSON { response in
            switch response.result {
            case .success(let json):
                let meta = Meta(json: json["meta"])
                let attempts = json["attempts"]
                    .arrayValue
                    .map { Attempt(json: $0, stepBlockName: stepName) }
                success(attempts, meta)
            case .failure(let error):
                errorHandler(error.localizedDescription)
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
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
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
