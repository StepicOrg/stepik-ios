//
//  LessonPlainObject.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct LessonPlainObject: Hashable {
    let id: Int
    let steps: [Int]
    let title: String
    let slug: String
    let timeToComplete: Double

    var hashValue: Int {
        // TODO: Written for Swift 4.1 compatibility, replace with `Hasher` Swift 4.2.
        // https://github.com/apple/swift-evolution/blob/master/proposals/0206-hashable-enhancements.md
        return id.hashValue ^ title.hashValue ^ slug.hashValue
            ^ timeToComplete.hashValue &* 16777619
    }
}

extension LessonPlainObject {
    init(lesson: Lesson) {
        self.id = lesson.id
        self.steps = lesson.stepsArray
        self.title = lesson.title
        self.slug = lesson.slug
        self.timeToComplete = lesson.timeToComplete
    }

    init(lesson: KnowledgeGraphLesson) {
        self.id = lesson.id
        self.steps = []
        self.title = ""
        self.slug = ""
        self.timeToComplete = 0
    }
}
