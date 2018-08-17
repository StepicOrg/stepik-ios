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

final class EnrollmentServiceMock: EnrollmentService, PromiseReturnable {
    var resultToBeReturned: Promise<Course> = Promise(error: NSError.mockError)

    func joinCourse(_ course: Course) -> Promise<Course> {
        return resultToBeReturned
    }
}
