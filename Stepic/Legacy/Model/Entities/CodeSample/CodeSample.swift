//
//  CodeSample.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class CodeSample: NSManagedObject {
    override var description: String {
        "CodeSample(input: \(self.input), output: \(self.output)"
    }

    required convenience init(input: String, output: String) {
        self.init()
        initialize(input: input, output: output)
    }

    func initialize(input: String, output: String) {
        self.input = input
        self.output = output
    }

    func update(input: String, output: String) {
        initialize(input: input, output: output)
    }
}
