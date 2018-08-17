//
//  KnowledgeGraphVertex.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public final class KnowledgeGraphVertex<T: Hashable & Codable>: Vertex<T>, Codable {
    public var title: String
    public var lessons = [KnowledgeGraphLesson]()

    init(id: T, title: String = "") {
        self.title = title
        super.init(id: id)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let id = try values.decode(T.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        lessons = try values.decode([KnowledgeGraphLesson].self, forKey: .lessons)

        super.init(id: id)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(lessons, forKey: .lessons)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case lessons
    }
}
