//
//  ContinueCourseOutputProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ContinueCourseOutputProtocol: class {
    func hideContinueCourse()
    func presentLastStep(course: Course, isAdaptive: Bool)
}
