//
//  UserCoursesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class UserCoursesAPI: APIEndpoint {
    override var name: String { return "user-courses" }

    func retrieve(page: Int = 1) -> Promise<([UserCourse], Meta)> {
        return Promise { seal in
            var params = Parameters()
            params["page"] = page

            retrieve.request(
                requestEndpoint: name,
                paramName: name,
                params: params,
                updatingObjects: Array<UserCourse>(),
                withManager: manager
            ).done { userCourses, meta, _ in
                seal.fulfill((userCourses, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
