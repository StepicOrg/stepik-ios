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
class ExecutionQueue: DictionarySerializable {
    fileprivate var queue: [Executable] = []

    var count: Int {
        return queue.count
    }

    func push(_ task: Executable) {
        queue += [task]
    }

    func executeAll(_ completion : @escaping ((ExecutionQueue) -> Void)) {
        print("executing all count -> \(count)")
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

        func executeTasks(completion: @escaping () -> Void) {
            guard queue.count > 0 else {
                completion()
                return
            }
            executeTask(id: 0, completion: completion)
        }

        func executeTask(id: Int, completion: @escaping () -> Void) {
            guard id < queue.count else {
                completion()
                return
            }
            let task = queue[id]
            task.execute( success: {
                executeTask(id: id + 1, completion: completion)
            }, failure: {
                executionError in
                if executionError == .retry {
                    notCompletedExecutionQueue.push(task)
                }
                executeTask(id: id + 1, completion: completion)
            })
        }

        executeTasks {
            completion(notCompletedExecutionQueue)
        }

    }

    init() {}

    required init?(dictionary: [String : Any]) {
        let taskRecoveryManager = PersistentTaskRecoveryManager(baseName: "Tasks")
        if let ids = dictionary["task_ids"] as? [String] {
            for id in ids {
                if let task = taskRecoveryManager.recoverTask(name: id) {
                    push(task)
                }
            }
        }
    }

    func serializeToDictionary() -> [String : Any] {
        var ids = [String]()
        for executable in queue {
            ids += [executable.id]
        }
        let res: [String: Any] = ["task_ids": ids]

        print(res)

        return res
    }

}
