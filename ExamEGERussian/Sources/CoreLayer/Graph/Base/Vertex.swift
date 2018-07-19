//
//  Vertex.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 09/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

public class Vertex<T: Hashable> {
    public var data: T

    init(data: T) {
        self.data = data
    }
}

extension Vertex: Hashable {
    public var hashValue: Int {
        return "\(data)".hashValue
    }

    static public func == (lhs: Vertex, rhs: Vertex) -> Bool {
        return lhs.data == rhs.data
    }
}

extension Vertex: CustomStringConvertible {
    public var description: String {
        return "\(data)"
    }
}
