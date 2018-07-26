//
//  CourseService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseService: class {

    /// Method is used to fetch Course objects from Stepik API
    ///
    /// - Parameter ids: Ids Course objects
    /// - Returns: Promise with a result of an array of Course objects from API.
    func fetchCourses(with ids: [Int]) -> Promise<[Course]>

    /// Method is used to obtain Course objects from cache with ids
    ///
    /// - Parameter ids: Ids Course objects
    /// - Returns: Promise with a result of an array of Course objects from cache.
    func obtainCourses(with ids: [Int]) -> Promise<[Course]>
}
