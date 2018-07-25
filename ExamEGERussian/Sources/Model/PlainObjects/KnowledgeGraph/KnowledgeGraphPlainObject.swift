//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct KnowledgeGraphPlainObject: Codable {
    let goals: [GoalPlainObject]
    let topics: [TopicPlainObject]
    let topicsMap: [TopicsMapPlainObject]

    enum CodingKeys: String, CodingKey {
        case goals
        case topics
        case topicsMap = "topics-map"
    }

    init(goals: [GoalPlainObject], topics: [TopicPlainObject], topicsMap: [TopicsMapPlainObject]) {
        self.goals = goals
        self.topics = topics
        self.topicsMap = topicsMap
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        goals = try container.decode([GoalPlainObject].self, forKey: .goals)
        topics = try container.decode([TopicPlainObject].self, forKey: .topics)
        topicsMap = try container.decode([TopicsMapPlainObject].self, forKey: .topicsMap)
    }
}
