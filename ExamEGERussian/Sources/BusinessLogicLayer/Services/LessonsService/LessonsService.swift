//
//  LessonsService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol LessonsService: class {
    /// Method is used to fetch lessons from Stepik API.
    ///
    /// - Parameter ids: Lessons ids.
    /// - Returns: Promise with an array of LessonPlainObjects.
    func fetchLessons(with ids: [Int]) -> Promise<[LessonPlainObject]>
    /// Method is used to obtain lessons from cache.
    ///
    /// - Parameter ids: Lessons ids.
    /// - Returns: Promise with an array of cached LessonPlainObjects.
    func obtainLessons(with ids: [Int]) -> Promise<[LessonPlainObject]>
    /// Method is used to get progress of the lesson using API request.
    ///
    /// - Parameters:
    ///   - id: Lesson id.
    ///   - stepsService: StepsService implementation for getting progress.
    /// - Returns: Promise with the value between 0 to 1.
    func fetchProgress(id: Int, stepsService: StepsService) -> Promise<Double>
    /// Method is used to get progresses of the lessons using API request.
    ///
    /// - Parameters:
    ///   - ids: An array of the lessons ids.
    ///   - stepsService: StepsService implementation for getting progress.
    /// - Returns: Promise with an array of the values between 0 to 1.
    func fetchProgresses(ids: [Int], stepsService: StepsService) -> Promise<[Double]>
    /// Method is used to obtain progress of the lesson from cache.
    ///
    /// - Parameters:
    ///   - id: Lesson id.
    ///   - stepsService: StepsService implementation for getting progress.
    /// - Returns: Guarantee with the value between 0 to 1.
    func obtainProgress(id: Int, stepsService: StepsService) -> Guarantee<Double>
    /// Method is used to obtain progresses of the lessons from cache.
    ///
    /// - Parameters:
    ///   - ids: An array of the lessons ids.
    ///   - stepsService: StepsService implementation for getting progress.
    /// - Returns: Guarantee with an array of the values between 0 to 1.
    func obtainProgresses(ids: [Int], stepsService: StepsService) -> Guarantee<[Double]>
}
