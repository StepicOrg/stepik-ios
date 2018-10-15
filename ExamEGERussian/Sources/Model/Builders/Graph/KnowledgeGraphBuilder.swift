//
//  KnowledgeGraphBuilder.swift
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
            graph.addVertex(
                KnowledgeGraphVertex(
                    id: $0.id,
                    title: $0.title,
                    topicDescription: $0.description
                )
            )
        }
        graphPlainObject.topics.filter {
            $0.requiredFor != nil
        }.forEach { topic in
            guard let (source, _) = graph[topic.id],
                  let requiredFor = topic.requiredFor else {
                return
            }

            requiredFor.forEach {
                guard let (destination, _) = graph[$0] else {
                    return
                }

                graph.add(from: source, to: destination)
            }
        }
        graphPlainObject.topicsMap.forEach { topicMap in
            guard let (vertex, _) = graph[topicMap.id] else {
                return
            }

            let graphLessons = topicMap.lessons.map {
                KnowledgeGraphLesson(
                    id: $0.id,
                    type: $0.type,
                    courseId: $0.course,
                    description: $0.description
                )
            }
            vertex.lessons.append(contentsOf: graphLessons)
        }

        return graph
    }
}
