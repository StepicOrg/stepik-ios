//
//  ExecutionQueues.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Contains all ExecutionQueues
 */
class ExecutionQueues {
    private init() {}
    static let sharedQueues = ExecutionQueues()
    
    var connectionAvailableExecutionQueue = ExecutionQueue()
}