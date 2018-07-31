//
//  StepPlainObject.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct StepPlainObject {
    enum StepType: String {
        case text
        case choice
        case string
        case number
        case freeAnswer = "free-answer"
        case math
        case sorting
        case matching
        case fillBlanks = "fill-blanks"
        case code
        case sql
        case table
    }

    let id: Int
    let lessonId: Int
    let position: Int
    let text: String
    let type: StepType
}
