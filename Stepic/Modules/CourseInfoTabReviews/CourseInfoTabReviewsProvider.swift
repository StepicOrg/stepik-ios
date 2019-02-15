//
//  CourseInfoTabReviewsProvider.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabReviewsProviderProtocol: class {
    func fetchCached(course: Course) -> Promise<([CourseReview], Meta)>
    func fetchRemote(course: Course, page: Int) -> Promise<([CourseReview], Meta)>
}

final class CourseInfoTabReviewsProvider: CourseInfoTabReviewsProviderProtocol {
    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol
    private let courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol

    init(
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol,
        courseReviewsNetworkService: CourseReviewsNetworkServiceProtocol
    ) {
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.courseReviewsNetworkService = courseReviewsNetworkService
    }

    func fetchCached(course: Course) -> Promise<([CourseReview], Meta)> {
        return Promise { seal in
            self.courseReviewsPersistenceService.fetch(by: course.id).done {
                seal.fulfill(($0, Meta.oneAndOnlyPage))
            }.catch { _ in
                seal.reject(Error.persistenceFetchFailed)
            }
        }
    }

    func fetchRemote(course: Course, page: Int) -> Promise<([CourseReview], Meta)> {
        return Promise { seal in
            self.courseReviewsNetworkService.fetch(by: course.id, page: page).done { reviews, meta in
                reviews.forEach { $0.course = course }
                seal.fulfill((reviews, meta))
                CoreDataHelper.instance.save()
            }.catch { _ in
                seal.reject(Error.networkFetchFailed)
            }
        }
    }

    enum Error: Swift.Error {
        case persistenceFetchFailed
        case networkFetchFailed
    }
}
