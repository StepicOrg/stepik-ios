//
//  CourseListOutputProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListOutputProtocol: class {
    func presentCourseInfo(course: Course)
    func presentCourseSyllabus(course: Course)
    func presentLastStep(course: Course, isAdaptive: Bool)

    func presentEmptyState(sourceModule: CourseListInputProtocol)
    func presentError(sourceModule: CourseListInputProtocol)
}
