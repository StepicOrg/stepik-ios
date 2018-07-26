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
}
