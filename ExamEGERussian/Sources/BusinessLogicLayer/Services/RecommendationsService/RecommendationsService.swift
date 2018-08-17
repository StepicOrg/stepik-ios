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
    private let lessonsService: LessonsService

    init(recommendationsAPI: RecommendationsAPI, lessonsService: LessonsService) {
        self.recommendationsAPI = recommendationsAPI
        self.lessonsService = lessonsService
    }

    func fetchIdsForCourseWithId(_ courseId: Int, batchSize: Int) -> Promise<[Int]> {
        return recommendationsAPI.retrieve(course: courseId, count: batchSize)
    }

    func fetchLessonsForCourseWithId(_ courseId: Int, batchSize: Int) -> Promise<[LessonPlainObject]> {
        return fetchIdsForCourseWithId(courseId, batchSize: batchSize).then { lessonsIds in
            self.lessonsService.fetchLessons(with: lessonsIds)
        }
    }
}
