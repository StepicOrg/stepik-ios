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
    private let progressService: ProgressService
    private let enrollmentService: EnrollmentService

    init(coursesAPI: CoursesAPI,
         progressesService: ProgressService,
         enrollmentService: EnrollmentService
    ) {
        self.coursesAPI = coursesAPI
        self.progressService = progressesService
        self.enrollmentService = enrollmentService
    }

    // MARK: - Public API

    func fetchCourses(with ids: [Int]) -> Promise<[CoursePlainObject]> {
        return fetchManagedCourses(with: ids).mapValues {
            CoursePlainObject(course: $0)
        }
    }

    func obtainCourses(with ids: [Int]) -> Promise<[CoursePlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return Course.fetchAsync(ids).mapValues { CoursePlainObject(course: $0) }
    }

    func fetchProgresses(coursesIds ids: [Int]) -> Promise<[CoursePlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        var courses = [Course]()

        return Course.fetchAsync(ids).then { cachedCourses -> Promise<[ProgressPlainObject]> in
            courses = cachedCourses
            let progressesIds = courses.compactMap {
                $0.progressId
            }

            return self.progressService.fetchProgresses(with: progressesIds)
        }.then { plainProgresses -> Promise<[Progress]> in
            Progress.getProgresses(plainProgresses.map { $0.id })
        }.then { progresses -> Promise<[CoursePlainObject]> in
            progresses.forEach { progress in
                guard let course = courses.filter({ $0.progressId == progress.id }).first else {
                    return
                }
                course.progress = progress
            }
            CoreDataHelper.instance.save()

            return .value(courses.map { CoursePlainObject(course: $0) })
        }
    }

    func joinCourses(with ids: [Int]) -> Promise<[CoursePlainObject]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return obtainCourses(with: ids).then { courses -> Promise<[Int]> in
            var ids = Set(ids)
            courses
                .filter { $0.enrolled }
                .map { $0.id }
                .forEach { ids.remove($0) }

            return .value(Array(ids))
        }.then { ids -> Promise<[Course]> in
            self.fetchManagedCourses(with: ids)
        }.then { courses in
            when(fulfilled: courses.map { self.joinCourse($0) })
        }.then { courses in
            self.fetchProgresses(coursesIds: courses.map { $0.id })
        }
    }

    // MARK: - Private API

    private func fetchManagedCourses(with ids: [Int]) -> Promise<[Course]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return Course.fetchAsync(ids).then { courses in
            self.coursesAPI.retrieve(ids: ids, existing: courses)
        }
    }

    private func joinCourse(_ course: Course) -> Promise<Course> {
        guard !course.enrolled else {
            return .value(course)
        }

        return enrollmentService.joinCourse(course)
    }
}
