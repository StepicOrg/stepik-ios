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
    /// Method is used to fetch courses from Stepik API.
    ///
    /// - Parameter ids: Courses ids.
    /// - Returns: `Promise<[CoursePlainObject]]>` if the fetch was successfully sent. \
    ///   Returns `error` if an error occurred.
    func fetchCourses(with ids: [Int]) -> Promise<[CoursePlainObject]>
    /// Method is used to obtain Course objects from cache with ids.
    ///
    /// - Parameter ids: Courses ids.
    /// - Returns: `Promise<[CoursePlainObject]]>` if the courses was successfully \
    ///   obtained from the cache. Returns `error` if an error occurred.
    func obtainCourses(with ids: [Int]) -> Promise<[CoursePlainObject]>
    /// Method is used to joining courses by their ids.
    ///
    /// - Parameter ids: Courses ids.
    /// - Returns: An array of joined courses with element of type `CoursePlainObject`.
    func joinCourses(with ids: [Int]) -> Promise<[CoursePlainObject]>
    /// Method is used to fetch progresses for `Course` objects from Stepik API.
    ///
    /// - Parameter ids: Courses ids.
    /// - Returns: Promise with an array of `Course` objects, that contains referenced `Progress` object.
    func fetchProgresses(coursesIds ids: [Int]) -> Promise<[CoursePlainObject]>
}
