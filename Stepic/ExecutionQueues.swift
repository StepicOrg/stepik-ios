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
    fileprivate init() {}
    static let sharedQueues = ExecutionQueues()
    
    var connectionAvailableExecutionQueue = ExecutionQueue()
    var connectionAvailableExecutionQueueKey = "connectionAvailableExecutionQueueKey"
    
    
    func setUpQueueObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ExecutionQueues.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    @objc func reachabilityChanged(_ notification: Foundation.Notification) {
        if ConnectionHelper.shared.isReachable {
            executeConnectionAvailableQueue()
        }
    }
    
    func executeConnectionAvailableQueue() {
        connectionAvailableExecutionQueue.executeAll { 
            newQueue in 
            print("could not execute \(newQueue.count) tasks, rewriting the queue")
            self.connectionAvailableExecutionQueue = newQueue
            let queuePersistencyManager = PersistentQueueRecoveryManager(baseName: "Queues")
            queuePersistencyManager.writeQueue(ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue, key: ExecutionQueues.sharedQueues.connectionAvailableExecutionQueueKey)
        }
    }
    
    func recoverQueuesFromPersistentStore() {
        let queueRecoveryManager = PersistentQueueRecoveryManager(baseName: "Queues")
        if let recoveredConnectionAvailableExecutionQueue = queueRecoveryManager.recoverQueue(connectionAvailableExecutionQueueKey) {
            connectionAvailableExecutionQueue = recoveredConnectionAvailableExecutionQueue
        } else {
            print("failed to recover connection available queue from persistent store")
        }
    }
    
}
