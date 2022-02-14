//
//  ViewsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class ViewsAPI: APIEndpoint {
    override class var name: String { "views" }

    func create(view: StepikModelView) -> Promise<Void> {
        self.create.request(
            requestEndpoint: Self.name,
            paramName: "view",
            creatingObject: view,
            withManager: self.manager
        )
    }

    func create(step stepId: Int, assignment assignmentId: Int?) -> Promise<Void> {
        self.create(view: StepikModelView(step: stepId, assignment: assignmentId))
    }

    //TODO: Do not delete this until ViewsCreateError is handled correctly & device executable tasks are improved
    @discardableResult
    func create(
        stepId id: Int,
        assignment: Int?,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping () -> Void,
        error errorHandler: @escaping (ViewsCreateError) -> Void
    ) -> Request? {
        var params: Parameters = [:]

        if let assignment = assignment {
            params = [
                "view": [
                    "step": "\(id)",
                    "assignment": "\(assignment)"
                ]
            ]
        } else {
            params = [
                "view": [
                    "step": "\(id)",
                    "assignment": NSNull()
                ]
            ]
        }

        return self.manager.request(
            "\(StepikApplicationsInfo.apiURL)/views",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        ).responseSwiftyJSON { response in
            switch response.result {
            case .success:
                guard let statusCode = response.response?.statusCode else {
                    return errorHandler(.other(error: nil, code: nil, message: nil))
                }

                switch statusCode {
                case 200..<300:
                    success()
                case 401:
                    errorHandler(.notAuthorized)
                default:
                    errorHandler(.other(error: nil, code: statusCode, message: nil))
                }
            case .failure(let error):
                errorHandler(.other(error: error, code: nil, message: nil))
            }
        }
    }
}

enum ViewsCreateError: Error {
    case notAuthorized
    case other(error: Error?, code: Int?, message: String?)
}
