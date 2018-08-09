//
//  KnowledgeGraph.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class KnowledgeGraph: AdjacencyListGraph<String> {
    typealias Element = (key: KnowledgeGraphVertex<String>, value: [KnowledgeGraphVertex<String>])

    var count: Int {
        return adjacency.keys.count
    }

    override func instantiateVertex(id: String) -> KnowledgeGraphVertex<String> {
        return KnowledgeGraphVertex(id: id)
    }

    subscript(index: Int) -> Element {
        let index = adjacency.index(adjacency.startIndex, offsetBy: index)
        guard let element = adjacency[index] as? Element else {
            fatalError("KnowledgeGraph must contains vertices of the KnowledgeGraphVertex type")
        }
        return element
    }

    subscript(id: String) -> Element? {
        return getElement(by: id)
    }

    private func getElement(by id: String) -> Element? {
        guard let index = adjacency.index(forKey: Vertex(id: id)) else {
            return nil
        }
        guard let element = adjacency[index] as? Element else {
            fatalError("KnowledgeGraph must contains vertices of the KnowledgeGraphVertex type")
        }
        return element
    }
}
