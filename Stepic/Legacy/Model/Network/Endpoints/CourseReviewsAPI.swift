//
//  CourseReviewsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class CourseReviewsAPI: APIEndpoint {
    override var name: String { "course-reviews" }

    /// Get course reviews by course id.
    func retrieve(courseID: Course.IdType, page: Int = 1) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            let parameters: Parameters = [
                "course": courseID,
                "page": page
            ]

            CourseReview.fetch(courseID: courseID).then {
                cachedReviews -> Promise<([CourseReview], Meta, JSON)> in
                self.retrieve.request(
                    requestEndpoint: self.name,
                    paramName: self.name,
                    params: parameters,
                    updatingObjects: cachedReviews,
                    withManager: self.manager
                )
            }.done { reviews, meta, _ in
                seal.fulfill((reviews, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    /// Get course review by course id and user id.
    func retrieve(courseID: Course.IdType, userID: User.IdType) -> Promise<([CourseReview], Meta)> {
        Promise { seal in
            let parameters: Parameters = [
                "course": courseID,
                "user": userID
            ]

            CourseReview.fetch(courseID: courseID, userID: userID).then {
                cachedReviews -> Promise<([CourseReview], Meta, JSON)> in
                self.retrieve.request(
                    requestEndpoint: self.name,
                    paramName: self.name,
                    params: parameters,
                    updatingObjects: cachedReviews,
                    withManager: self.manager
                )
            }.done { reviews, meta, _ in
                seal.fulfill((reviews, meta))
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func create(
        courseID: Course.IdType,
        userID: User.IdType,
        score: Int,
        text: String
    ) -> Promise<CourseReview> {
        let courseReview = CourseReview(courseID: courseID, userID: userID, score: score, text: text)
        return Promise { seal in
            self.create.request(
                requestEndpoint: self.name,
                paramName: self.name,
                creatingObject: courseReview,
                withManager: self.manager
            ).done { courseReview, _ in
                seal.fulfill(courseReview)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func update(_ courseReview: CourseReview) -> Promise<CourseReview> {
        self.update.request(
            requestEndpoint: self.name,
            paramName: self.name,
            updatingObject: courseReview,
            withManager: self.manager
        )
    }

    func delete(id: CourseReview.IdType) -> Promise<Void> {
        self.delete.request(
            requestEndpoint: self.name,
            deletingId: id,
            withManager: self.manager
        ).then {
            CourseReview.delete(id)
        }
    }
}
