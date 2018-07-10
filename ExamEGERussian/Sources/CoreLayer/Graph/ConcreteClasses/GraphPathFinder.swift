//
//  GraphPathFinder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 10/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

/**
 * Given a connected directed graph, finds first paths between any two input verticies.
 */
public class GraphPathFinder<T> where T: Hashable {

    private let graph: AbstractGraph<T>

    init(_ graph: AbstractGraph<T>) {
        self.graph = graph
    }

    // MARK: Public API

    public func isReachable(source: Vertex<T>, destination: Vertex<T>) -> Bool {
        var reachable = false

        dfs(source: source) { (vertex, stop) in
            if vertex == destination {
                reachable = true
                stop = true
            }
        }

        return reachable
    }

    public func verticesLead(to destination: Vertex<T>) -> [Vertex<T>] {
        var vertices = [Vertex<T>]()

        graph.vertices.forEach { vertex in
            guard vertex != destination else { return }
            if isReachable(source: vertex, destination: destination) {
                vertices.append(vertex)
            }
        }

        return vertices
    }

    // MARK: Private API

    private func dfs(source: Vertex<T>, block: (_ vertex: Vertex<T>, _ stop: inout Bool) -> Void) {
        var stack = [Vertex<T>]()
        stack.append(source)

        var set = Set<Vertex<T>>()
        set.insert(source)

        var stop = false

        while let current = stack.popLast() {
            block(current, &stop)

            guard !stop else { return }

            let neighbours = graph.edges(from: current)
            for neighbour in neighbours {
                let destination = neighbour.destination
                if !set.contains(destination) {
                    stack.append(destination)
                    set.insert(destination)
                }
            }
        }
    }

}
