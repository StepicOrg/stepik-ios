//
//  UserCoursesAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

final class UserCoursesAPI: APIEndpoint {
    override var name: String { "user-courses" }

    func retrieve(
        page: Int = 1,
        isArchived: Bool? = nil,
        isFavorite: Bool? = nil
    ) -> Promise<([UserCourse], Meta)> {
        Promise { seal in
            var params = Parameters()
            params["page"] = page

            if let isArchived = isArchived {
                params[UserCourse.JSONKey.isArchived.rawValue] = String(isArchived)
            }
            if let isFavorite = isFavorite {
                params[UserCourse.JSONKey.isFavorite.rawValue] = String(isFavorite)
            }

            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                updatingObjects: [UserCourse](),
                withManager: self.manager
            ).done { userCourses, meta, _ in
                seal.fulfill((userCourses, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func retrieve(courseID: Course.IdType) -> Promise<([UserCourse], Meta)> {
        Promise { seal in
            var params = Parameters()
            params["course"] = courseID

            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                withManager: self.manager
            ).done { userCourses, meta, _ in
                seal.fulfill((userCourses, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func update(_ userCourse: UserCourse) -> Promise<UserCourse> {
        self.update.request(
            requestEndpoint: self.name,
            paramName: "userCourse",
            updatingObject: userCourse,
            withManager: self.manager
        )
    }
}
