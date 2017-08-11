//
//  ViewsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ViewsAPI: APIEndpoint {
    let name = "views"

    @discardableResult func create(stepId id: Int, assignment: Int?, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping () -> Void, error errorHandler: @escaping (ViewsCreateError) -> Void) -> Request? {
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

        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/views", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
//            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
//                json = response.result.value!
            }
            let response = response.response

            if let e = error {
                errorHandler(.other(error: e, code: nil, message: nil))
                return
            }

            guard let code = response?.statusCode else {
                errorHandler(.other(error: nil, code: nil, message: nil))
                return
            }

            switch code {
            case 200..<300:
                success()
                return
            case 401:
                errorHandler(.notAuthorized)
                return
            default:
                errorHandler(.other(error: nil, code: code, message: nil))
                return
            }
        })
    }
}

enum ViewsCreateError: Error {
    case notAuthorized, other(error: Error?, code: Int?, message: String?)
}
