//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct KnowledgeGraphPlainObject: Codable {
    let goals: [KnowledgeGraphGoalPlainObject]
    let topics: [KnowledgeGraphTopicPlainObject]
    let topicsMap: [KnowledgeGraphTopicsMapPlainObject]

    enum CodingKeys: String, CodingKey {
        case goals
        case topics
        case topicsMap = "topics-map"
    }

    init(goals: [KnowledgeGraphGoalPlainObject], topics: [KnowledgeGraphTopicPlainObject], topicsMap: [KnowledgeGraphTopicsMapPlainObject]) {
        self.goals = goals
        self.topics = topics
        self.topicsMap = topicsMap
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        goals = try container.decode([KnowledgeGraphGoalPlainObject].self, forKey: .goals)
        topics = try container.decode([KnowledgeGraphTopicPlainObject].self, forKey: .topics)
        topicsMap = try container.decode([KnowledgeGraphTopicsMapPlainObject].self, forKey: .topicsMap)
    }
}
