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
final class ExecutionQueues {
    private static let networkReachabilityService: NetworkReachabilityServiceProtocol = NetworkReachabilityService()

    static let sharedQueues = ExecutionQueues()

    private init() {}

    private(set) var connectionAvailableExecutionQueue = ExecutionQueue()
    static let connectionAvailableExecutionQueueKey = "connectionAvailableExecutionQueueKey"

    func setUpQueueObservers() {
        Self.networkReachabilityService.startListening { status in
            if status == .reachable {
                self.executeConnectionAvailableQueue()
            }
        }
    }

    func executeConnectionAvailableQueue() {
        self.connectionAvailableExecutionQueue.executeAll { newQueue in
            print("could not execute \(newQueue.count) tasks, rewriting the queue")
            self.connectionAvailableExecutionQueue = newQueue

            let queuePersistencyManager = PersistentQueueRecoveryManager(baseName: "Queues")
            queuePersistencyManager.writeQueue(
                Self.sharedQueues.connectionAvailableExecutionQueue,
                key: Self.connectionAvailableExecutionQueueKey
            )
        }
    }

    func recoverQueuesFromPersistentStore() {
        let queueRecoveryManager = PersistentQueueRecoveryManager(baseName: "Queues")

        guard let recoveredConnectionAvailableExecutionQueue = queueRecoveryManager.recoverQueue(
            Self.connectionAvailableExecutionQueueKey
        ) else {
            return print("failed to recover connection available queue from persistent store")
        }

        self.connectionAvailableExecutionQueue = recoveredConnectionAvailableExecutionQueue
    }
}
