//
//  AdjacencyListGraph.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 10/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public class AdjacencyListGraph<T>: AbstractGraph<T> where T: Hashable, T: Comparable {

    public var adjacency = [Vertex<T>: [Vertex<T>]]()

    public required init() {
        super.init()
    }

    public override var vertices: [Vertex<T>] {
        return sortedVertices()
    }

    public override var edges: [Edge<T>] {
        var allEdges = Set<Edge<T>>()

        for (vertex, adjacentVertices) in adjacency {
            adjacentVertices.forEach {
                allEdges.insert(Edge(source: vertex, destination: $0))
            }
        }

        return Array(allEdges)
    }

    public override var description: String {
        return buildDescription(from: vertices)
    }

    public override func addVertex(_ vertex: Vertex<T>) {
        if adjacency[vertex] == nil {
            adjacency[vertex] = []
        }
    }

    public func instantiateVertex(id: T) -> Vertex<T> {
        return Vertex(id: id)
    }

    @discardableResult
    public override func createVertex(id: T) -> Vertex<T> {
        let vertex = instantiateVertex(id: id)
        addVertex(vertex)

        return vertex
    }

    public override func add(from source: Vertex<T>, to destination: Vertex<T>) {
        if adjacency[source] == nil {
            createVertex(id: source.id)
        }

        guard let adjacentVertices = adjacency[source],
              !adjacentVertices.contains(destination) else {
            return
        }

        adjacency[source]?.append(destination)
    }

    public override func edges(from source: Vertex<T>) -> [Edge<T>] {
        return adjacency[source]?.map { Edge(source: source, destination: $0) } ?? []
    }

    func sortedVertices(_ by: ((Vertex<T>, Vertex<T>) -> Bool) = { $0.id < $1.id }) -> [Vertex<T>] {
        return adjacency.keys.sorted(by: by)
    }

    // MARK: Private Helpers

    private func buildDescription(from vertices: [Vertex<T>]) -> String {
        var result = ""

        for vertex in sortedVertices() {
            var adjacentString = ""

            guard let adjacentVertices = adjacency[vertex] else {
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

// MARK: - AdjacencyListGraph (Topological Sort) -

extension AdjacencyListGraph {
    /// Topological sort using depth-first search.
    ///
    /// - Returns: Sorted vertices on success and `throws` if graph has a cycle.
    public func topologicalSort() throws -> [Vertex<T>] {
        var hasCycle = false
        var stack = [Vertex<T>]()
        var colorMap = [Vertex<T>: VertexColor]()

        // Returns `true` if has cycle.
        func dfs(_ node: Vertex<T>) -> Bool {
            if colorMap[node] == .gray {
                return true
            }
            if colorMap[node] == .black {
                return false
            }
            colorMap[node] = .gray

            for nodeInAdjacencyList in adjacency[node]! {
                if dfs(nodeInAdjacencyList) {
                    return true
                }
            }

            stack.append(node)
            colorMap[node] = .black

            return false
        }

        for (node, _) in adjacency {
            hasCycle = dfs(node)
            if hasCycle {
                throw AdjacencyListGraphError.hasCycle
            }
        }

        return stack.reversed()
    }

    public enum AdjacencyListGraphError: Error {
        case hasCycle
    }

    private enum VertexColor {
        case white
        case gray
        case black
    }
}
