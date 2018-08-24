//
//  TopologicalSortTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 24/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

// Note: Any order where all the arrows are going from left to right will do.
class TopologicalSortTests: XCTestCase {
    func testSuccessWithFourVertices() {
        let graph = KnowledgeGraph()

        let node1 = graph.createVertex(id: "1")
        let node2 = graph.createVertex(id: "2")
        let node3 = graph.createVertex(id: "3")
        let node4 = graph.createVertex(id: "4")

        graph.add(from: node1, to: node4)
        graph.add(from: node4, to: node2)
        graph.add(from: node4, to: node3)
        graph.add(from: node3, to: node2)

        // Add edge that produces cycle
        graph.add(from: node2, to: node1)

        do {
            _ = try graph.topologicalSort()
            XCTFail("Must has a cycle")
        } catch let error {
            if let error = error as? KnowledgeGraph.AdjacencyListGraphError {
                XCTAssertTrue(error == KnowledgeGraph.AdjacencyListGraphError.hasCycle)
            } else {
                XCTFail("Must throw AdjacencyListGraph.AdjacencyListGraphError")
            }
        }
    }

    func testFailureWithCycle() {
        let graph = KnowledgeGraph()

        let node1 = graph.createVertex(id: "1")
        let node2 = graph.createVertex(id: "2")
        let node3 = graph.createVertex(id: "3")
        let node4 = graph.createVertex(id: "4")

        graph.add(from: node1, to: node4)
        graph.add(from: node4, to: node2)
        graph.add(from: node4, to: node3)
        graph.add(from: node3, to: node2)

        let result = try! graph.topologicalSort().map { $0.id }

        XCTAssertEqual(result, ["1", "4", "3", "2"])
    }

    func testTopologicalSort() {
        let graph = KnowledgeGraph()

        let node5 = graph.createVertex(id: "5")
        let node7 = graph.createVertex(id: "7")
        let node3 = graph.createVertex(id: "3")
        let node11 = graph.createVertex(id: "11")
        let node8 = graph.createVertex(id: "8")
        let node2 = graph.createVertex(id: "2")
        let node9 = graph.createVertex(id: "9")
        let node10 = graph.createVertex(id: "10")

        graph.add(from: node5, to: node11)
        graph.add(from: node7, to: node11)
        graph.add(from: node7, to: node8)
        graph.add(from: node3, to: node8)
        graph.add(from: node3, to: node10)
        graph.add(from: node11, to: node2)
        graph.add(from: node11, to: node9)
        graph.add(from: node11, to: node10)
        graph.add(from: node8, to: node9)

        let result = try! graph.topologicalSort()
        let possibleSolutions = [
            ["5", "7", "3", "8", "11", "10", "9", "2"],
            ["7", "3", "5", "11", "2", "10", "8", "9"],
            ["5", "7", "11", "2", "3", "10", "8", "9"],
            ["7", "5", "3", "8", "11", "9", "2", "10"],
            ["3", "7", "5", "10", "8", "11", "9", "2"],
            ["3", "7", "5", "8", "11", "2", "9", "10"]
        ]

        let firstId = result.first!.id
        let zeroInDegrees = ["3", "7", "5"]
        XCTAssertTrue(zeroInDegrees.contains(firstId))

        checkIsValidTopologicalSort(graph, result as! [KnowledgeGraph.Node])
        XCTAssertTrue(possibleSolutions.contains(result.map { $0.id }))
    }

    func testTopologicalSortEdgeLists() {
        let p1 = ["A B", "A C", "B C", "B D", "C E", "C F", "E D", "F E", "G A", "G F"]
        let p2 = ["B C", "C D", "C G", "B F", "D G", "G E", "F G", "F G"]
        let p3 = ["S V", "S W", "V T", "W T"]
        let p4 = ["5 11", "7 11", "7 8", "3 8", "3 10", "11 2", "11 9", "11 10", "8 9"]

        let data = [p1, p2, p3, p4]

        for d in data {
            let graph = KnowledgeGraph()
            graph.loadEdgeList(d)

            let sorted = try! graph.topologicalSort()
            checkIsValidTopologicalSort(graph, sorted as! [KnowledgeGraph.Node])
        }
    }

    // The topological sort is valid if a node does not have any of its
    // predecessors in its adjacency list.
    func checkIsValidTopologicalSort(_ graph: KnowledgeGraph, _ a: [KnowledgeGraph.Node]) {
        for i in stride(from: (a.count - 1), to: 0, by: -1) {
            if let neighbors = graph.adjacency[a[i]] {
                for j in stride(from: (i - 1), through: 0, by: -1) {
                    XCTAssertFalse(neighbors.contains(a[j]), "\(a) is not a valid topological sort")
                }
            }
        }
    }
}

extension KnowledgeGraph {
    public func loadEdgeList(_ lines: [String]) {
        for line in lines {
            let items = line.components(separatedBy: " ").filter { s in !s.isEmpty }
            if self[items[0]] == nil {
                createVertex(id: items[0])
            }
            if self[items[1]] == nil {
                createVertex(id: items[1])
            }

            add(from: self[items[0]]!.key, to: self[items[1]]!.key)
        }
    }
}
