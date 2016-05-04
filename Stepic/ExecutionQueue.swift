//
//  ExecutionQueue.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Contains and runs a queue of Executable objects 
 */
class ExecutionQueue {
    private var queue : [Executable] = []
    
    var count : Int {
        return queue.count
    }
    
    func push(task: Executable) {
        queue += [task]
    }
    
    func executeAll(completion : (ExecutionQueue -> Void)) {
        var notCompletedExecutionQueue = ExecutionQueue()
        var executedCount = 0

        func didExecuteAll() -> Bool {
            return notCompletedExecutionQueue.count + executedCount == queue.count
        }
        
        func completeIfAllExecuted() {
            if didExecuteAll() {
                completion(notCompletedExecutionQueue)
            }
        }
                
        for executableTask in queue {
            executableTask.execute(
                success: {
                    executedCount += 1
                    completeIfAllExecuted()
                }, failure: {
                    notCompletedExecutionQueue.push(executableTask)
                    completeIfAllExecuted()                
                }
            )
        }
        
        
    }
}