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
    private enum EnrollmentServiceError: Error {
        case joinCourseFailed
    }

    private let enrollmentsAPI: EnrollmentsAPI

    init(enrollmentsAPI: EnrollmentsAPI) {
        self.enrollmentsAPI = enrollmentsAPI
    }

    func joinCourse(_ course: Course) -> Promise<Course> {
        return Promise { seal in
            self.enrollmentsAPI.joinCourse(course).done {
                seal.fulfill(course)
            }.catch { _ in
                seal.reject(EnrollmentServiceError.joinCourseFailed)
            }
        }
    }
}
