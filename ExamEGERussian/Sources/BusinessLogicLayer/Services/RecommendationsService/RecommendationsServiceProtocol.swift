//
//  RecommendationsServiceProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol RecommendationsServiceProtocol: class {
    /// Method is used to fetch recommendations for a giving course using API request.
    ///
    /// - Parameters:
    ///   - courseId: Unique identifier of the course for which the recommendations search \
    ///               will be performed.
    ///   - batchSize: The returns count of the recommedations for course.
    /// - Returns: Promise with an array of unique identifiers of the recommended **lessons**.
    func fetchForCourseWithId(_ courseId: Int, batchSize: Int) -> Promise<[Int]>
}

extension RecommendationsServiceProtocol {
    /// Method is used to fetch recommendations for a giving course using API request with a default \
    /// batch size. **Default batch size is equal to 1**.
    ///
    /// - Parameters:
    ///   - courseId: Unique identifier of the course for which the recommendations search \
    ///               will be performed.
    ///   - batchSize: The returns count of the recommedations for course.
    /// - Returns: Promise with an array of unique identifiers of the recommended **lessons**.
    func fetchForCourseWithId(_ courseId: Int) -> Promise<[Int]> {
        return fetchForCourseWithId(courseId, batchSize: 1)
    }
}
