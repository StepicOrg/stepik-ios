//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct KnowledgeGraphTopicsMapPlainObject: Codable {
    let id: String
    let lessons: [KnowledgeGraphLessonPlainObject]

    init(id: String, lessons: [KnowledgeGraphLessonPlainObject]) {
        self.id = id
        self.lessons = lessons
    }
}
