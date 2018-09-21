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
    public var lessons = [KnowledgeGraphLesson]()
    public var progress: Double
    public var timeToComplete: Double

    var containsPractice: Bool {
        return lessons.contains(where: { $0.type == .practice })
    }

    init(id: T, title: String = "", progress: Double = 0, timeToComplete: Double = 0) {
        self.title = title
        self.progress = progress
        self.timeToComplete = timeToComplete
        super.init(id: id)
    }
}
