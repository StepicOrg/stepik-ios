//
//  AdjacencyList.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

/// Implements graph data structure using adjacency list.
public class AdjacencyList<T: Hashable> {
    
    /// Dictionary where the key is a vertex and the value is an array of edges.
    public var adjacencyDict: [Vertex<T>: [Edge<T>]] = [:]
    
    init() {}
    
}

// MARK: - AdjacencyList: GraphProtocol -

extension AdjacencyList: GraphProtocol {
    
    // MARK: GraphProtocol
    
    public typealias Element = T
    
    public var vertices: [Vertex<Element>] {
        return Array(adjacencyDict.keys)
    }
    
    public var edges: [Edge<Element>] {
        var allEdges = Set<Edge<Element>>()
        
        for edges in adjacencyDict.values {
            edges.forEach { allEdges.insert($0) }
        }
        
        return Array(allEdges)
    }
    
    public func createVertex(data: Element) -> Vertex<Element> {
        let vertex = Vertex(data: data)
        
        if adjacencyDict[vertex] == nil {
            adjacencyDict[vertex] = []
        }
        
        return vertex
    }
    
    public func add(from source: Vertex<Element>, to destination: Vertex<Element>) {
        addDirectedEdge(from: source, to: destination)
    }
    
    public func edges(from source: Vertex<Element>) -> [Edge<Element>]? {
        return adjacencyDict[source]
    }
    
    /// Builds string with the vertex, and all the vertices it’s connected to by an edge.
    public var description: CustomStringConvertible {
        return buildDescription(from: vertices)
    }
    
    // MARK: Private Helpers
    
    private func addDirectedEdge(from source: Vertex<Element>, to destination: Vertex<Element>) {
        let edge = Edge(source: source, destination: destination)
        
        guard let vertices = adjacencyDict[source],
            !vertices.contains(edge) else {
            return
        }
        
        adjacencyDict[source]?.append(edge)
    }
    
    private func buildDescription(from vertices: [Vertex<Element>]) -> String {
        var result = ""
        
        for vertex in vertices {
            var edgeString = ""
            guard let edges = adjacencyDict[vertex] else { return edgeString }
            for (index, edge) in edges.enumerated() {
                if index != edges.count - 1 {
                    edgeString.append("\(edge.destination), ")
                } else {
                    edgeString.append("\(edge.destination)")
                }
            }
            result.append("\(vertex) ---> [ \(edgeString) ] \n")
        }
        
        return result
    }
    
}

// MARK: - AdjacencyList where Element: Comparable -

extension AdjacencyList where Element: Comparable {
    
    public var vertices: [Vertex<Element>] {
        let sortedKeys = adjacencyDict.keys.sorted { $0.data < $1.data }
        return Array(sortedKeys)
    }
    
    public var description: CustomStringConvertible {
        return buildDescription(from: vertices)
    }
    
}
