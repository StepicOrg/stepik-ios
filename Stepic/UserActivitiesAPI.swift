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
    @discardableResult func retrieve(user userId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((UserActivity) -> Void), error errorHandler: @escaping ((Error) -> Void)) -> Request? {

        retrieve(user: userId).then {
            UserActivity in
            success(UserActivity)
        }.catch {
            error in
            errorHandler(error)
        }

        return nil
    }
}
