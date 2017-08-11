//
//  Executable.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Protocol for executable objects
 */
protocol Executable {
    func execute(success: @escaping (() -> Void), failure: @escaping ((ExecutionError) -> Void))
    var type: ExecutableTaskType { get }
    var id: String {get}
}

enum ExecutionError: Error {
    case retry, remove
}
