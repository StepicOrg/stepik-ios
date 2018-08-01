//
//  CourseServiceImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class CourseServiceImpl: CourseService {
    private let coursesAPI: CoursesAPI

    init(coursesAPI: CoursesAPI) {
        self.coursesAPI = coursesAPI
    }

    func fetchCourses(with ids: [Int]) -> Promise<[Course]> {
        return obtainCourses(with: ids).then { courses in
            self.coursesAPI.retrieve(ids: ids, existing: courses)
        }
    }

    func obtainCourses(with ids: [Int]) -> Promise<[Course]> {
        return Course.fetchAsync(ids)
    }
}
