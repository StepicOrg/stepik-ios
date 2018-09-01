//
//  TrainingRouterProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TrainingRouterProtocol: class {
    func showAuth()
    func showTheory(lesson: LessonPlainObject)
    func showPractice(courseId: String)
}
