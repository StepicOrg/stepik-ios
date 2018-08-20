//
//  JoinCourseUseCase.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class JoinCourseUseCase: JoinCourseUseCaseProtocol {
    private let courseService: CourseService
    private let enrollmentService: EnrollmentService

    init(courseService: CourseService, enrollmentService: EnrollmentService) {
        self.courseService = courseService
        self.enrollmentService = enrollmentService
    }

    func joinCourses(_ ids: [Int]) -> Promise<[CoursePlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return courseService.obtainCourses(with: ids).then { courses -> Promise<[Int]> in
            var ids = Set(ids)
            courses
                .filter { $0.enrolled }
                .map { $0.id }
                .forEach { ids.remove($0) }

            return .value(Array(ids))
        }.then { ids -> Promise<[Course]> in
            self.courseService.fetchCourses(with: ids)
        }.then { courses in
            when(fulfilled: courses.map { self.joinCourse($0) })
        }.then { courses in
            self.courseService.fetchProgresses(coursesIds: courses.map { $0.id })
        }.mapValues {
            CourseMapper(course: $0).plainObject
        }
    }

    private func joinCourse(_ course: Course) -> Promise<Course> {
        guard !course.enrolled else {
            return .value(course)
        }

        return enrollmentService.joinCourse(course)
    }
}
