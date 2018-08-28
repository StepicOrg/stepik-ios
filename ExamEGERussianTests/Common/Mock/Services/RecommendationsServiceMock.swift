//
//  RecommendationsServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 21/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class RecommendationsServiceMock: RecommendationsServiceProtocol {
    var idsResultToBeReturned: Promise<[Int]> = Promise(error: NSError.mockError)
    var lessonsResultToBeReturned: Promise<[LessonPlainObject]> = Promise(error: NSError.mockError)

    func fetchLessonsForCourseWithId(_ courseId: Int, batchSize: Int) -> Promise<[LessonPlainObject]> {
        return lessonsResultToBeReturned
    }

    func fetchIdsForCourseWithId(_ courseId: Int, batchSize: Int) -> Promise<[Int]> {
        return idsResultToBeReturned
    }
}
