//
//  ServiceComponents.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ServiceComponents: class {
    var userRegistrationService: UserRegistrationService { get }
    var graphService: GraphService { get }
    var lessonsService: LessonsService { get }
    var courseService: CourseService { get }
}
