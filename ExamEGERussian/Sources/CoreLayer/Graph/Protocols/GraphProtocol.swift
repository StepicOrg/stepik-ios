//
//  GraphProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public protocol GraphProtocol {
    
    associatedtype Element: Hashable
    
    var vertices: [Vertex<Element>] { get }
    
    var edges: [Edge<Element>] { get }
    
    var description: CustomStringConvertible { get }
    
    /// Utility method to create a vertex.
    /// - parameter data: Data associated with the vertex.
    func createVertex(data: Element) -> Vertex<Element>
    
    /// Adds directed edge between two vertices.
    /// - parameter source: Source vertex.
    /// - parameter destination: Destination vertex.
    func add(from source: Vertex<Element>, to destination: Vertex<Element>)
    
    /// Retrieves all edges that source vertex connects to.
    /// - parameter source: Source vertex.
    /// - returns: Returns associated edges with vertex.
    func edges(from source: Vertex<Element>) -> [Edge<Element>]?
    
}
