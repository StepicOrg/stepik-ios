//
//  Vertex.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public class Vertex<T: Hashable> {
    public let id: T

    public init(id: T) {
        self.id = id
    }
}

extension Vertex: Hashable {
    public var hashValue: Int {
        return "\(id)".hashValue
    }

    static public func == (lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        return "\(id)"
    }
}
