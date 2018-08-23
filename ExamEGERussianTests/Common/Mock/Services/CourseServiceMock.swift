//
//  CourseServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class CourseServiceMock: BaseServiceMock<[CoursePlainObject]>, CourseService {
    func fetchCourses(with ids: [Int]) -> Promise<[CoursePlainObject]> {
        return resultToBeReturned
    }

    func obtainCourses(with ids: [Int]) -> Promise<[CoursePlainObject]> {
        return resultToBeReturned
    }

    func fetchProgresses(coursesIds ids: [Int]) -> Promise<[CoursePlainObject]> {
        return resultToBeReturned
    }

    func joinCourses(with ids: [Int]) -> Promise<[CoursePlainObject]> {
        return resultToBeReturned
    }
}
