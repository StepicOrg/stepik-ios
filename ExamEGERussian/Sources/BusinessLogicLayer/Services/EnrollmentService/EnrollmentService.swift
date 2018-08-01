//
//  EnrollmentService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol EnrollmentService: class {
    /// Method is used to joining Course object with specified id.
    ///
    /// - Parameter course: Course to join.
    /// - Returns: Promise when fullfilled.
    func joinCourse(_ course: Course) -> Promise<Course>
}
