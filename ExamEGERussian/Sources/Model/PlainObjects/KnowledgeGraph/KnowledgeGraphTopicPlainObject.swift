//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct KnowledgeGraphTopicPlainObject: Codable {
    let id: String
    let title: String
    let requiredFor: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case requiredFor = "required-for"
    }

    init(id: String, title: String, requiredFor: String?) {
        self.id = id
        self.title = title
        self.requiredFor = requiredFor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        requiredFor = try container.decodeIfPresent(String.self, forKey: .requiredFor)
    }
}
