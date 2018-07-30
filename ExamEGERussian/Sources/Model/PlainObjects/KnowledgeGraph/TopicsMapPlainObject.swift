//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct TopicsMapPlainObject: Codable {
    let id: String
    let lessons: [LessonPlainObject]

    init(id: String, lessons: [LessonPlainObject]) {
        self.id = id
        self.lessons = lessons
    }
}
