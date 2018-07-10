//
//  Edge.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public struct Edge<T: Hashable> {
    public var source: Vertex<T>
    public var destination: Vertex<T>
}

extension Edge: Hashable {
    
    public var hashValue: Int {
        return "\(source)\(destination)".hashValue
    }
    
    static public func ==(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
        return lhs.source == rhs.source && lhs.destination == rhs.destination
    }
    
}

extension Edge: CustomStringConvertible {
    public var description: String {
        return "\(source.description) -> \(destination.description)"
    }
}
