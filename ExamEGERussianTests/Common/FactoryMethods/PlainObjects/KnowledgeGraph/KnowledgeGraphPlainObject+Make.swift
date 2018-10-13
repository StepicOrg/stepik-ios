//
//  KnowledgeGraphPlainObject+Make.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

extension KnowledgeGraphPlainObject {
    static func make() -> KnowledgeGraphPlainObject {
        let goals = [
            KnowledgeGraphGoalPlainObject(
                title: "Морфология",
                id: "morph",
                requiredTopics: ["slitno-razdelno"]
            )
        ]
        let topics = [
            KnowledgeGraphTopicPlainObject(
                id: "slitno-razdelno",
                title: "B13 Слитное раздельное написание",
                description: "Тут что-то будет",
                requiredFor: nil
            ),
            KnowledgeGraphTopicPlainObject(
                id: "pristavki",
                title: "B9 Приставки",
                description: "А тут что-то другое",
                requiredFor: [
                    "slitno-razdelno"
                ]
            )
        ]
        let lessons = [
            KnowledgeGraphLessonPlainObject(
                id: 82810,
                type: "theory",
                course: 7798,
                description: "Description 82810"
            ),
            KnowledgeGraphLessonPlainObject(
                id: 82809,
                type: "theory",
                course: 7798,
                description: "Description 82809"
            ),
            KnowledgeGraphLessonPlainObject(
                id: 86295,
                type: "theory",
                course: 7798,
                description: "Description 86295"
            ),
            KnowledgeGraphLessonPlainObject(
                id: 86297,
                type: "theory",
                course: 7798,
                description: "Description 82297"
            ),
            KnowledgeGraphLessonPlainObject(
                id: 6000,
                type: "practice",
                course: 7798,
                description: "Description 6000"
            )
        ]
        let topicsMap = [
            KnowledgeGraphTopicsMapPlainObject(id: "slitno-razdelno", lessons: lessons)
        ]

        return KnowledgeGraphPlainObject(goals: goals, topics: topics, topicsMap: topicsMap)
    }
}
