//
//  StepsService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol StepsService: class {
    /// Method is used to fetch steps from Stepik API.
    ///
    /// - Parameter ids: Steps ids.
    /// - Returns: Promise with an array of StepPlainObjects.
    func fetchSteps(with ids: [Int]) -> Promise<[StepPlainObject]>
    /// Method is used to fetch steps for a lesson.
    ///
    /// - Parameter lesson: Lesson for which steps will be fetched.
    /// - Returns: Promise with an array of StepPlainObjects.
    func fetchSteps(for lesson: LessonPlainObject) -> Promise<[StepPlainObject]>
    /// Method is used to obtain steps from cache.
    ///
    /// - Parameter ids: Steps ids.
    /// - Returns: Promise with an array of cached StepPlainObject.
    func obtainSteps(with ids: [Int]) -> Promise<[StepPlainObject]>
    /// Method is used to obtain steps from cache for a lesson.
    ///
    /// - Parameter lesson: Lesson for which steps will be obtained from cache.
    /// - Returns: Promise with an array of cached StepPlainObjects.
    func obtainSteps(for lesson: LessonPlainObject) -> Promise<[StepPlainObject]>
    /// Method is used to fetch progresses for steps from Stepik API.
    ///
    /// - Parameter ids: Lesson for which steps progresses will be fetched.
    /// - Returns: Promise with an array of `StepPlainObject` objects.
    func fetchProgresses(stepsIds ids: [Int]) -> Promise<[StepPlainObject]>
    /// Updates step progress value.
    ///
    /// - Parameter stepsIds: Steps ids.
    /// - Returns: Promise with an array of `StepPlainObject` objects.
    func markAsSolved(stepsIds ids: [Int]) -> Promise<[StepPlainObject]>
}

extension StepsService {
    func fetchSteps(for lesson: LessonPlainObject) -> Promise<[StepPlainObject]> {
        return fetchSteps(with: lesson.steps)
    }

    func obtainSteps(for lesson: LessonPlainObject) -> Promise<[StepPlainObject]> {
        return obtainSteps(with: lesson.steps)
    }
}
