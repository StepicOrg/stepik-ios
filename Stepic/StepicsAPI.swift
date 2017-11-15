//
//  StepicsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StepicsAPI {

    init() {}

    let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return SessionManager(configuration: configuration)
    }()

    @discardableResult func retrieveCurrentUser(_ headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (User) -> Void, error errorHandler: @escaping (Error) -> Void) -> Request {

        let params = Parameters()

        print("headers while retrieving user before: \(AuthInfo.shared.initialHTTPHeaders)")

        return manager.request("\(StepicApplicationsInfo.apiURL)/stepics/1", parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
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
//            let response = response.response

            print("headers while retrieving user: \(String(describing: request?.allHTTPHeaderFields)), retrieved user: \(json)")

            if let e = error as NSError? {
                print(e.localizedDescription)

                errorHandler(e)
                return
            }

            let user: User = User(json: json["users"].arrayValue[0])
            success(user)
        })

    }
}
