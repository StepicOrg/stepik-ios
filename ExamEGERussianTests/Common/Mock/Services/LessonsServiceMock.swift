//
//  LessonsServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class LessonsServiceMock: LessonsService {
    var lessonsResult: Promise<[LessonPlainObject]> = Promise(error: NSError.mockError)
    var fetchProgressResult: Promise<Double> = Promise(error: NSError.mockError)
    var fetchProgressesResult: Promise<[Double]> = Promise(error: NSError.mockError)
    var cacheProgressResult: Guarantee<Double> = Guarantee(resolver: { _ in })
    var cacheProgressesResult: Guarantee<[Double]> = Guarantee(resolver: { _ in })

    func fetchLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        return lessonsResult
    }

    func obtainLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        return lessonsResult
    }

    func fetchProgress(id: Int, stepsService: StepsService) -> Promise<Double> {
        return fetchProgressResult
    }

    func fetchProgresses(ids: [Int], stepsService: StepsService) -> Promise<[Double]> {
        return fetchProgressesResult
    }

    func obtainProgress(id: Int, stepsService: StepsService) -> Guarantee<Double> {
        return cacheProgressResult
    }

    func obtainProgresses(ids: [Int], stepsService: StepsService) -> Guarantee<[Double]> {
        return cacheProgressesResult
    }
}
