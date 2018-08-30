//
//  KGraphLesson.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public struct KnowledgeGraphLesson {
    let id: Int
    let type: LessonType
    let courseId: String

    public enum LessonType: String {
        case theory
        case practice

        public init(rawValue: String) {
            switch rawValue {
            case "theory":
                self = .theory
            case "practice":
                self = .practice
            default:
                self = LessonType.default
            }
        }

        static var `default`: LessonType {
            return .theory
        }
    }
}

extension KnowledgeGraphLesson {
    init(id: Int, type: String, courseId: String) {
        self.id = id
        self.type = LessonType(rawValue: type)
        self.courseId = courseId
    }
}
