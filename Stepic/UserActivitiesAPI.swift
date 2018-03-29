//
//  UserActivitiesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class UserActivitiesAPI: APIEndpoint {
    override var name: String { return "user-activities" }

    func retrieve(user userId: Int) -> Promise<UserActivity> {
        return retrieve.request(requestEndpoint: "user-activities", paramName: "user-activities", id: userId, withManager: manager)
    }
}

//deprecations
extension UserActivitiesAPI {
    @available(*, deprecated, message: "Use retrieve with promises instead")
    @discardableResult func retrieve(user userId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((UserActivity) -> Void), error errorHandler: @escaping ((UserRetrieveError) -> Void)) -> Request {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)/\(userId)", headers: headers).responseSwiftyJSON({
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

            if let e = error as NSError? {
                print("RETRIEVE user-activities/\(userId): error \(e.domain) \(e.code): \(e.localizedDescription)")
                errorHandler(.connectionError)
                return
            }

            if response?.statusCode != 200 {
                print("RETRIEVE user-activities/\(userId): bad response status code \(String(describing: response?.statusCode))")
                errorHandler(.badStatus)
                return
            }

            guard let userActivityJSON = json["user-activities"].arrayValue.first else { return }
            let userActivity = UserActivity(json: userActivityJSON)

            success(userActivity)

            return
            }
        )
    }
}

//TODO: This is never used, remove
@available(*, deprecated, message: "Use RetrieveError instead")
enum UserRetrieveError: Error {
    case connectionError, badStatus
}
