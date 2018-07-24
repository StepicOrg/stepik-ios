//
//  LessonsService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol LessonsService: class {
    func obtainLessons(with ids: [Int]) -> Promise<[LessonPlainObject]>
}
