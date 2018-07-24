//
//  AbstractGraphBuilderImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class KnowledgeGraphBuilder: AbstractGraphBuilder {
    private let graphPlainObject: KnowledgeGraphPlainObject

    init(graphPlainObject: KnowledgeGraphPlainObject) {
        self.graphPlainObject = graphPlainObject
    }

    func build() -> AbstractGraph<String> {
        let graph = KnowledgeGraph()

        graphPlainObject.topics.forEach {
            graph.addVertex(KnowledgeGraphVertex(id: $0.id, title: $0.title))
        }
        graphPlainObject.topics
            .filter { $0.requiredFor != nil }
            .forEach { topic in
                guard let (source, _) = graph[topic.id],
                    let (destination, _) = graph[topic.requiredFor!] else {
                        return
                }
                graph.add(from: source, to: destination)
            }
        graphPlainObject.topicsMap.forEach { topicMap in
            guard let (vertex, _) = graph[topicMap.id] else { return }
            vertex.lessons.append(contentsOf:
                topicMap.lessons.map {
                    KnowledgeGraphLesson(id: $0.id, type: $0.type, courseId: $0.course)
                }
            )
        }

        return graph
    }
}
