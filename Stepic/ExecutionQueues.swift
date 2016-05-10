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
    
}