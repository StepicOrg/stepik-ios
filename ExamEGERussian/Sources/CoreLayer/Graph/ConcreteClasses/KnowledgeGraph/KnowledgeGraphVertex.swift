//
//  KnowledgeGraphVertex.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public final class KnowledgeGraphVertex<T: Hashable>: Vertex<T> {
    public var title: String
    public var topicDescription: String
    public var lessons = [KnowledgeGraphLesson]()

    var containsPractice: Bool {
        return lessons.contains(where: { $0.type == .practice })
    }

    init(id: T, title: String = "", topicDescription: String = "") {
        self.title = title
        self.topicDescription = topicDescription
        super.init(id: id)
    }
}
