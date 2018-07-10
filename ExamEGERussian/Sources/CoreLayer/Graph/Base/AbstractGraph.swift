//
//  AbstractGraph.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 10/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public class AbstractGraph<T: Hashable>: CustomStringConvertible {
    
    public required init() {}
    
    public var description: String {
        fatalError("abstract property accessed")
    }
    
    public var vertices: [Vertex<T>] {
        fatalError("abstract property accessed")
    }
    
    public var edges: [Edge<T>] {
        fatalError("abstract property accessed")
    }
    
    /// Utility method to create a vertex.
    /// - parameter data: Data associated with the vertex.
    public func createVertex(data: T) -> Vertex<T> {
        fatalError("abstract function called")
    }
    
    /// Adds directed edge between two vertices.
    /// - parameter source: Source vertex.
    /// - parameter destination: Destination vertex.
    public func add(from source: Vertex<T>, to destination: Vertex<T>) {
        fatalError("abstract function called")
    }
    
    /// Retrieves all edges that source vertex connects to.
    /// - parameter source: Source vertex.
    /// - returns: Returns associated edges with vertex.
    public func edges(from source: Vertex<T>) -> [Edge<T>] {
        fatalError("abstract function called")
    }
    
}
