//
//  CodeSample.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class CodeSample: NSManagedObject {
    
    convenience required init(input: String, output: String) {
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
