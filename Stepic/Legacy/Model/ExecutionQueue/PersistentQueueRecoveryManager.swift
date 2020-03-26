//
//  PersistentQueueRecoveryManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 10.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

final class PersistentQueueRecoveryManager: PersistentRecoveryManager {
    override func recoverObjectFromDictionary(_ dictionary: [String: Any]) -> DictionarySerializable? {
        ExecutionQueue(dictionary: dictionary)
    }

    func recoverQueue(_ key: String) -> ExecutionQueue? {
        self.recoverObjectWithKey(key) as? ExecutionQueue
    }

    func writeQueue(_ queue: ExecutionQueue, key: String) {
        self.writeObjectWithKey(key, object: queue)
    }
}
