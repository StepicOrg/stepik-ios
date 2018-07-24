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

    var graph: AbstractGraph<Int>!

    override func setUp() {
        super.setUp()
        graph = AdjacencyListGraph()
    }

    override func tearDown() {
        super.tearDown()
        graph = nil
    }

    func testSortedGraphKeysCustomStringConvertible() {
        let a = graph.createVertex(id: 1)
        let b = graph.createVertex(id: 2)

        graph.add(from: a, to: b)

        XCTAssertEqual(graph.description.description, "1 ---> [ 2 ] \n2 ---> [  ] \n")
    }

    func testEdgesFromReturnsCorrectEdgeInSingleEdgeDirected() {
        let a = graph.createVertex(id: 1)
        let b = graph.createVertex(id: 2)

        graph.add(from: a, to: b)

        let edgesFromA = graph.edges(from: a)
        let edgesFromB = graph.edges(from: b)

        XCTAssertEqual(edgesFromA.count, 1)
        XCTAssertEqual(edgesFromB.count, 0)

        XCTAssertEqual(edgesFromA.first?.destination, b)
    }

    func testEdgesFromReturnsCorrectEdgeInSingleEdgeUndirected() {
        let a = graph.createVertex(id: 1)
        let b = graph.createVertex(id: 2)

        graph.add(from: a, to: b)
        graph.add(from: b, to: a)

        let edgesFromA = graph.edges(from: a)
        let edgesFromB = graph.edges(from: b)

        XCTAssertEqual(edgesFromA.count, 1)
        XCTAssertEqual(edgesFromB.count, 1)

        XCTAssertEqual(edgesFromA.first?.destination, b)
        XCTAssertEqual(edgesFromB.first?.destination, a)
    }

    func testEdgesFromReturnsNoEdgesInNoEdgeGraph() {
        let a = graph.createVertex(id: 1)
        let b = graph.createVertex(id: 2)

        XCTAssertEqual(graph.edges(from: a).count, 0)
        XCTAssertEqual(graph.edges(from: b).count, 0)
    }

    func testEdgesFromReturnsCorrectEdgesInBiggerGraph() {
        let verticesCount = 10
        var vertices: [Vertex<Int>] = []

        for i in 0..<verticesCount {
            vertices.append(graph.createVertex(id: i))
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
            for j in i + 1..<verticesCount {
                graph.add(from: vertices[i], to: vertices[j])
            }
        }

        for i in 0..<verticesCount {
            let sourceEdges = graph.edges(from: vertices[i])
            let destinationVertices = sourceEdges.map { $0.destination }

            XCTAssertEqual(sourceEdges.count, verticesCount - i - 1)

            for j in i + 1..<verticesCount {
                XCTAssertTrue(destinationVertices.contains(vertices[j]))
            }
        }
    }

    func testSumOfAdjacencyListsIfEqualToEdges() {
        let a = graph.createVertex(id: 1)
        let b = graph.createVertex(id: 2)
        let c = graph.createVertex(id: 3)

        graph.add(from: a, to: b)
        graph.add(from: a, to: c)
        graph.add(from: b, to: c)

        XCTAssertEqual(graph.edges.count, 3)
    }

}
