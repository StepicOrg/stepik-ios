//
//  RecommendationsService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class RecommendationsService: RecommendationsServiceProtocol {
    private let recommendationsAPI: RecommendationsAPI

    init(recommendationsAPI: RecommendationsAPI) {
        self.recommendationsAPI = recommendationsAPI
    }

    func fetchForCourseWithId(_ courseId: Int, batchSize: Int) -> Promise<[Int]> {
        return recommendationsAPI.retrieve(course: courseId, count: batchSize)
    }
}
