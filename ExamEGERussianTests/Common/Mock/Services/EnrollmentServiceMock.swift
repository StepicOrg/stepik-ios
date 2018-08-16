//
//  EnrollmentServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class EnrollmentServiceMock: BaseServiceMock<Course>, EnrollmentService {
    func joinCourse(_ course: Course) -> Promise<Course> {
        return resultToBeReturned
    }
}
