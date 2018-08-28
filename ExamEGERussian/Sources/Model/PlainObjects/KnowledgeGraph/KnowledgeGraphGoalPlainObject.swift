//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct KnowledgeGraphGoalPlainObject: Codable {
    let title: String
    let id: String
    let requiredTopics: [String]

    enum CodingKeys: String, CodingKey {
        case title
        case id
        case requiredTopics = "required-topics"
    }

    init(title: String, id: String, requiredTopics: [String]) {
        self.title = title
        self.id = id
        self.requiredTopics = requiredTopics
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        id = try container.decode(String.self, forKey: .id)
        requiredTopics = try container.decode([String].self, forKey: .requiredTopics)
    }
}
