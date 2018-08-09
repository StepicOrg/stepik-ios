//
//  LessonPlainObject.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct LessonPlainObject: Codable {
    let id: Int
    let steps: [Int]
    let title: String
    let slug: String
}
