//
//  JoinCoursesUseCaseProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol JoinCourseUseCaseProtocol: class {
    func joinCourses(_ ids: [Int]) -> Promise<[CoursePlainObject]>
}
