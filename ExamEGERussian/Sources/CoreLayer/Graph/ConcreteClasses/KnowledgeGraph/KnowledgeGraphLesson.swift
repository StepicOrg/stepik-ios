//
//  KGraphLesson.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public struct KnowledgeGraphLesson: Codable {
    public enum LessonType: String, Codable {
        case theory
        case practice
    }

    let id: Int
    let type: LessonType
    let courseId: String
}

extension KnowledgeGraphLesson {
    init(id: Int, type: String, courseId: String) {
        self.id = id
        self.type = LessonType(rawValue: type)!
        self.courseId = courseId
    }
}
