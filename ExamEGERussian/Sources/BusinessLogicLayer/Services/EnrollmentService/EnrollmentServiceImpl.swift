//
//  EnrollmentServiceImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class EnrollmentServiceImpl: EnrollmentService {
    private let enrollmentsAPI: EnrollmentsAPI

    init(enrollmentsAPI: EnrollmentsAPI) {
        self.enrollmentsAPI = enrollmentsAPI
    }

    func joinCourse(_ course: Course) -> Promise<Course> {
        return enrollmentsAPI.joinCourse(course).then { _ -> Promise<Course> in
            course.enrolled = true

            return .value(course)
        }
    }
}
