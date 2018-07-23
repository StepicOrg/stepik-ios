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
        return adjacencies.keys.count
    }

    override func instantiateVertex(id: String) -> KnowledgeGraphVertex<String> {
        return KnowledgeGraphVertex(id: id)
    }

    subscript(index: Int) -> Element {
        let index = adjacencies.index(adjacencies.startIndex, offsetBy: index)
        guard let element = adjacencies[index] as? Element else {
            fatalError("KnowledgeGraph must contains vertices of the KnowledgeGraphVertex type")
        }
        return element
    }

    subscript(id: String) -> Element? {
        return getElement(by: id)
    }

    private func getElement(by id: String) -> Element? {
        guard let index = adjacencies.index(forKey: Vertex(id: id)) else { return nil }
        guard let element = adjacencies[index] as? Element else {
            fatalError("KnowledgeGraph must contains vertices of the KnowledgeGraphVertex type")
        }
        return element
    }
}
