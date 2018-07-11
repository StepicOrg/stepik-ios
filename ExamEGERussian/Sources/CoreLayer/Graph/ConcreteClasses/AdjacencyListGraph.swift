//
//  AdjacencyListGraph.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 10/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public class AdjacencyListGraph<T>: AbstractGraph<T> where T: Hashable, T: Comparable {

    public var adjacencies = [Vertex<T>: [Vertex<T>]]()

    public required init() {
        super.init()
    }

    public override var vertices: [Vertex<T>] {
        return adjacencies.keys.sorted { $0.data < $1.data }
    }

    public override var edges: [Edge<T>] {
        var allEdges = Set<Edge<T>>()

        for (vertex, adjacentVertices) in adjacencies {
            adjacentVertices.forEach { allEdges.insert(Edge(source: vertex, destination: $0)) }
        }

        return Array(allEdges)
    }

    public override var description: String {
        return buildDescription(from: vertices)
    }

    @discardableResult
    public override func createVertex(data: T) -> Vertex<T> {
        let vertex = Vertex(data: data)

        if adjacencies[vertex] == nil {
            adjacencies[vertex] = []
        }

        return vertex
    }

    public override func add(from source: Vertex<T>, to destination: Vertex<T>) {
        if adjacencies[source] == nil {
            createVertex(data: source.data)
        }

        guard let adjacentVertices = adjacencies[source],
            !adjacentVertices.contains(destination) else { return }

        adjacencies[source]?.append(destination)
    }

    public override func edges(from source: Vertex<T>) -> [Edge<T>] {
        return adjacencies[source]?.map { Edge(source: source, destination: $0) } ?? []
    }

    // MARK: Private Helpers

    private func buildDescription(from vertices: [Vertex<T>]) -> String {
        var result = ""

        for vertex in vertices {
            var adjacentString = ""

            guard let adjacentVertices = adjacencies[vertex] else {
                return adjacentString
            }

            for (index, destination) in adjacentVertices.enumerated() {
                if index != adjacentVertices.count - 1 {
                    adjacentString.append("\(destination), ")
                } else {
                    adjacentString.append("\(destination)")
                }
            }

            result.append("\(vertex) ---> [ \(adjacentString) ] \n")
        }

        return result
    }

}
