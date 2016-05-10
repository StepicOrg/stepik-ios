//
//  PersistentQueueRecoveryManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 10.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class PersistenQueueRecoveryManager : PersistentRecoveryManager {
    override func recoverObjectFromDictionary(dictionary: [String : AnyObject]) -> DictionarySerializable? {
        return ExecutionQueue(dictionary: dictionary)
    }
    
    func recoverQueue(key: String) -> ExecutionQueue?  {
        return recoverObjectWithKey(key) as? ExecutionQueue
    }
    
    func writeQueue(queue: ExecutionQueue, key: String) {
        writeObjectWithKey(key, object: queue)
    }
}