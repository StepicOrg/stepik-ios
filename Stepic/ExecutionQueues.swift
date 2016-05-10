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
    var connectionAvailableExecutionQueueKey = "connectionAvailableExecutionQueueKey"
    
    
    func setUpQueues() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ExecutionQueues.reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
    }
    
    @objc func reachabilityChanged(notification: NSNotification) {
        if Reachability.reachabilityForInternetConnection().isReachable() {
            executeConnectionAvailableQueue()
        }
    }
    
    func executeConnectionAvailableQueue() {
        connectionAvailableExecutionQueue.executeAll { 
            newQueue in 
            self.connectionAvailableExecutionQueue = newQueue
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