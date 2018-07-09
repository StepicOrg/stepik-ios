//
//  GraphTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 09/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class GraphTests: XCTestCase {
    
    func testSortedGraphKeysCustomStringConvertible() {
        let graph = AdjacencyList<Int>()
        
        let a = graph.createVertex(data: 1)
        let b = graph.createVertex(data: 2)
        
        graph.add(from: a, to: b)
        
        XCTAssertEqual(graph.description.description, "1 ---> [ 2 ] \n2 ---> [  ] \n")
    }
    
    func testEdgesFromReturnsCorrectEdgeInSingleEdgeDirected() {
        let graph = AdjacencyList<Int>()
        
        let a = graph.createVertex(data: 1)
        let b = graph.createVertex(data: 2)
        
        graph.add(from: a, to: b)
        
        guard let edgesFromA = graph.edges(from: a),
            let edgesFromB = graph.edges(from: b) else { return XCTFail() }
        
        XCTAssertEqual(edgesFromA.count, 1)
        XCTAssertEqual(edgesFromB.count, 0)
        
        XCTAssertEqual(edgesFromA.first?.destination, b)
    }
    
    func testEdgesFromReturnsCorrectEdgeInSingleEdgeUndirected() {
        let graph = AdjacencyList<Int>()
        
        let a = graph.createVertex(data: 1)
        let b = graph.createVertex(data: 2)
        
        graph.add(from: a, to: b)
        graph.add(from: b, to: a)
        
        guard let edgesFromA = graph.edges(from: a),
            let edgesFromB = graph.edges(from: b) else { return XCTFail() }
        
        XCTAssertEqual(edgesFromA.count, 1)
        XCTAssertEqual(edgesFromB.count, 1)
        
        XCTAssertEqual(edgesFromA.first?.destination, b)
        XCTAssertEqual(edgesFromB.first?.destination, a)
    }
    
    func testEdgesFromReturnsNoEdgesInNoEdgeGraph() {
        let graph = AdjacencyList<Int>()
        
        let a = graph.createVertex(data: 1)
        let b = graph.createVertex(data: 2)
        
        XCTAssertEqual(graph.edges(from: a)?.count, 0)
        XCTAssertEqual(graph.edges(from: b)?.count, 0)
    }
    
    func testEdgesFromReturnsCorrectEdgesInBiggerGraph() {
        let graph = AdjacencyList<Int>()
        let verticesCount = 10
        var vertices: [Vertex<Int>] = []
        
        for i in 0..<verticesCount {
            vertices.append(graph.createVertex(data: i))
        }
        
        /*
             0 ---> [ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]
             1 ---> [ 2, 3, 4, 5, 6, 7, 8, 9 ]
             2 ---> [ 3, 4, 5, 6, 7, 8, 9 ]
             3 ---> [ 4, 5, 6, 7, 8, 9 ]
             4 ---> [ 5, 6, 7, 8, 9 ]
             5 ---> [ 6, 7, 8, 9 ]
             6 ---> [ 7, 8, 9 ]
             7 ---> [ 8, 9 ]
             8 ---> [ 9 ]
             9 ---> [  ]
         */
        
        for i in 0..<verticesCount {
            for j in i+1..<verticesCount {
                graph.add(from: vertices[i], to: vertices[j])
            }
        }
        
        for i in 0..<verticesCount {
            let sourceEdges = graph.edges(from: vertices[i])!
            let destinationVertices = sourceEdges.map { $0.destination }
            
            XCTAssertEqual(sourceEdges.count, verticesCount - i - 1)
            
            for j in i+1..<verticesCount {
                XCTAssertTrue(destinationVertices.contains(vertices[j]))
            }
        }
    }
    
}
