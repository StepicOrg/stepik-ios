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

    init(coursesAPI: CoursesAPI, progressesService: ProgressService) {
        self.coursesAPI = coursesAPI
        self.progressService = progressesService
    }

    func fetchCourses(with ids: [Int]) -> Promise<[Course]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return obtainCourses(with: ids).then { courses in
            self.coursesAPI.retrieve(ids: ids, existing: courses)
        }
    }

    func obtainCourses(with ids: [Int]) -> Promise<[Course]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        return Course.fetchAsync(ids)
    }

    func fetchProgresses(coursesIds ids: [Int]) -> Promise<[Course]> {
        guard !ids.isEmpty else {
            return .value([])
        }

        var courses = [Course]()

        return obtainCourses(with: ids).then { cachedCourses -> Promise<[Progress]> in
            courses = cachedCourses
            let progressesIds = courses.compactMap {
                $0.progressId
            }

            return self.progressService.fetchProgresses(with: progressesIds)
        }.then { progresses -> Promise<[Course]> in
            progresses.forEach { progress in
                guard let course = courses.filter({ $0.progressId == progress.id }).first else {
                    return
                }
                course.progress = progress
            }
            CoreDataHelper.instance.save()

            return .value(courses)
        }
    }
}
