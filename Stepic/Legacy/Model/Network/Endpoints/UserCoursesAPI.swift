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
import SwiftyJSON

final class UserCoursesAPI: APIEndpoint {
    override class var name: String { "user-courses" }

    private let userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol

    init(
        userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol = UserCoursesPersistenceService()
    ) {
        self.userCoursesPersistenceService = userCoursesPersistenceService
        super.init()
    }

    func retrieve(
        page: Int = 1,
        isArchived: Bool? = nil,
        isFavorite: Bool? = nil,
        canBeReviewed: Bool? = nil,
        isDraft: Bool? = nil
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
            if let canBeReviewed = canBeReviewed {
                params[UserCourse.JSONKey.canBeReviewed.rawValue] = String(canBeReviewed)
            }
            if let isDraft = isDraft {
                params["is_draft"] = String(isDraft)
            }

            firstly { () -> Guarantee<[UserCourse]> in
                self.userCoursesPersistenceService.fetchAll()
            }.then { cachedUserCourses -> Promise<([UserCourse], Meta, JSON)> in
                self.retrieve.request(
                    requestEndpoint: Self.name,
                    paramName: Self.name,
                    params: params,
                    updatingObjects: cachedUserCourses,
                    withManager: self.manager
                )
            }.done { userCourses, meta, _ in
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

            firstly { () -> Guarantee<[UserCourse]> in
                self.userCoursesPersistenceService.fetch(courseID: courseID)
            }.then { cachedUserCourses -> Promise<([UserCourse], Meta, JSON)> in
                self.retrieve.request(
                    requestEndpoint: Self.name,
                    paramName: Self.name,
                    params: params,
                    updatingObjects: cachedUserCourses,
                    withManager: self.manager
                )
            }.done { userCourses, meta, _ in
                seal.fulfill((userCourses, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func update(_ userCourse: UserCourse) -> Promise<UserCourse> {
        self.update.request(
            requestEndpoint: Self.name,
            paramName: "userCourse",
            updatingObject: userCourse,
            withManager: self.manager
        )
    }
}
