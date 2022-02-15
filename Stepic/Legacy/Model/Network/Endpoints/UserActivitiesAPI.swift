//
//  UserActivitiesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class UserActivitiesAPI: APIEndpoint {
    override class var name: String { "user-activities" }

    func retrieve(user userId: Int) -> Promise<UserActivity> {
        self.retrieve.request(
            requestEndpoint: Self.name,
            paramName: Self.name,
            id: userId,
            withManager: self.manager
        )
    }
}

//deprecations
extension UserActivitiesAPI {
    @available(*, deprecated, message: "Use retrieve with promises instead")
    @discardableResult
    func retrieve(
        user userId: Int,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ((UserActivity) -> Void),
        error errorHandler: @escaping ((Error) -> Void)
    ) -> Request? {
        self.retrieve(user: userId).done { userActivity in
            success(userActivity)
        }.catch { error in
            errorHandler(error)
        }
        return nil
    }
}
