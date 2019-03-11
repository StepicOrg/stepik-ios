//
//  CourseReviewsNetworkService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseReviewsNetworkServiceProtocol: class {
    func fetch(by courseID: Course.IdType, page: Int) -> Promise<([CourseReview], Meta)>
}

final class CourseReviewsNetworkService: CourseReviewsNetworkServiceProtocol {
    private let courseReviewsAPI: CourseReviewsAPI

    init(courseReviewsAPI: CourseReviewsAPI) {
        self.courseReviewsAPI = courseReviewsAPI
    }

    func fetch(by courseID: Course.IdType, page: Int = 1) -> Promise<([CourseReview], Meta)> {
        return Promise { seal in
            self.courseReviewsAPI.retrieve(courseID: courseID, page: page).done { results, meta in
                seal.fulfill((results, meta))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
