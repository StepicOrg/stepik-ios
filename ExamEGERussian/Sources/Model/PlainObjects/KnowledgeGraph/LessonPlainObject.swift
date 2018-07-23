//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct LessonPlainObject: Codable {
    let id: Int
    let type: String
    let course: String

    init(id: Int, type: String, course: String) {
        self.id = id
        self.type = type
        self.course = course
    }
}
