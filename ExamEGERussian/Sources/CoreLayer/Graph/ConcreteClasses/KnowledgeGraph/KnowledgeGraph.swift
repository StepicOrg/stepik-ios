//
//  KnowledgeGraph.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class KnowledgeGraph: AdjacencyListGraph<String> {
    typealias Node = KnowledgeGraphVertex<String>
    typealias Element = (key: Node, value: [Node])

    var count: Int {
        return adjacency.keys.count
    }

    var isEmpty: Bool {
        return count == 0
    }

    var adjacencyLists: [Node: [Node]] {
        return adjacency as! [Node: [Node]]
    }

    override func instantiateVertex(id: String) -> Node {
        return KnowledgeGraphVertex(id: id)
    }

    subscript(index: Int) -> Element {
        let index = adjacencyLists.index(adjacencyLists.startIndex, offsetBy: index)
        return adjacencyLists[index]
    }

    subscript(id: String) -> Element? {
        return getElement(by: id)
    }

    func firstLesson(where predicate: (KnowledgeGraphLesson) -> Bool) -> KnowledgeGraphLesson? {
        for vertex in adjacencyLists.keys {
            if let lesson = vertex.lessons.first(where: predicate) {
                return lesson
            }
        }

        return nil
    }

    private func getElement(by id: String) -> Element? {
        guard let index = adjacency.index(forKey: Vertex(id: id)),
              let element = adjacency[index] as? Element else {
            return nil
        }

        return element
    }
}
