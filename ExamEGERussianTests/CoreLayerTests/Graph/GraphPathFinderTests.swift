//
//  GraphPathFinderTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 10/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class GraphPathFinderTests: XCTestCase {

    var graph: AbstractGraph<String>!

    override func setUp() {
        super.setUp()
        graph = AdjacencyListGraph()
    }

    override func tearDown() {
        super.tearDown()
        graph = nil
    }

    func testPathFinder() {
        // A: [B, D]
        // B: [C, D]
        // C: [E]
        // D: [F]
        // E: []
        // F: []

        let a = graph.createVertex(data: "A")
        let b = graph.createVertex(data: "B")
        let c = graph.createVertex(data: "C")
        let d = graph.createVertex(data: "D")
        let e = graph.createVertex(data: "E")
        let f = graph.createVertex(data: "F")

        graph.add(from: a, to: b)
        graph.add(from: a, to: d)
        graph.add(from: b, to: d)
        graph.add(from: b, to: c)
        graph.add(from: c, to: e)
        graph.add(from: d, to: f)

        var result: [Vertex<String>]
        let pathFinder = GraphPathFinder(graph)

        result = pathFinder.verticesLead(to: f)
        if result == [a, b, d] || result == [a, d, b] {
            XCTAssert(true)
        } else {
            XCTFail("Incorrect vertices")
        }

        result = pathFinder.verticesLead(to: d)
        XCTAssertEqual(result, [a, b])

        result = pathFinder.verticesLead(to: b)
        XCTAssertEqual(result, [a])

        result = pathFinder.verticesLead(to: c)
        XCTAssertEqual(result, [a, b])

        result = pathFinder.verticesLead(to: e)
        XCTAssertEqual(result, [a, b, c])
    }

}
