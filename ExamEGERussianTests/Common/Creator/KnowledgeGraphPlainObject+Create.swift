//
//  KnowledgeGraphPlainObject.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

extension KnowledgeGraphPlainObject {
    static func createGraph() -> KnowledgeGraphPlainObject {
        let goals = [
            GoalPlainObject(title: "Морфология", id: "morph", requiredTopics: ["slitno-razdelno"])
        ]
        let topics = [
            TopicPlainObject(id: "slitno-razdelno", title: "B13 Слитное раздельное написание", requiredFor: nil),
            TopicPlainObject(id: "pristavki", title: "B9 Приставки", requiredFor: "slitno-razdelno")
        ]
        let lessons = [
            LessonPlainObject(id: 82810, type: "theory", course: "7798"),
            LessonPlainObject(id: 82809, type: "theory", course: "7798"),
            LessonPlainObject(id: 86295, type: "theory", course: "7798"),
            LessonPlainObject(id: 86297, type: "theory", course: "7798"),
            LessonPlainObject(id: 6000, type: "practice", course: "7798")
        ]
        let topicsMap = [
            TopicsMapPlainObject(id: "slitno-razdelno", lessons: lessons)
        ]

        return KnowledgeGraphPlainObject(goals: goals, topics: topics, topicsMap: topicsMap)
    }
}
