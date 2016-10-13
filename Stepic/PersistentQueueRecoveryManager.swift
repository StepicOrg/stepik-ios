//
//  PersistentQueueRecoveryManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 10.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class PersistentQueueRecoveryManager : PersistentRecoveryManager {
    
    override func recoverObjectFromDictionary(_ dictionary: [String : Any]) -> DictionarySerializable? {
        return ExecutionQueue(dictionary: dictionary)
    }
    
    func recoverQueue(_ key: String) -> ExecutionQueue?  {
        return recoverObjectWithKey(key) as? ExecutionQueue
    }
    
    func writeQueue(_ queue: ExecutionQueue, key: String) {
        writeObjectWithKey(key, object: queue)
    }
}
