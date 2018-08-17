//
//  KnowledgeGraph.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class KnowledgeGraph: AdjacencyListGraph<String>, Codable {
    typealias Element = (key: KnowledgeGraphVertex<String>, value: [KnowledgeGraphVertex<String>])

    var count: Int {
        return adjacency.keys.count
    }

    public required init() {
        super.init()
    }

    public init(from decoder: Decoder) throws {
        super.init()

        let values = try decoder.container(keyedBy: CodingKeys.self)
        adjacency = try values.decode(
            [KnowledgeGraphVertex<String>: [KnowledgeGraphVertex<String>]].self,
            forKey: CodingKeys.adjacency
        )
    }

    func encode(to encoder: Encoder) throws {
        guard let adjacency = adjacency as? [KnowledgeGraphVertex<String>: [KnowledgeGraphVertex<String>]] else {
            fatalError("failed to encode")
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(adjacency, forKey: CodingKeys.adjacency)
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

    enum CodingKeys: String, CodingKey {
        case adjacency
    }
}
