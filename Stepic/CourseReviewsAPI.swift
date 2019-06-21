//
//  CourseReviewsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import SwiftyJSON

final class CourseReviewsAPI: APIEndpoint {
    override var name: String { return "course-reviews" }

    func retrieve(courseID: Course.IdType, page: Int = 1) -> Promise<([CourseReview], Meta)> {
        return Promise { seal in
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
}
