//
//  PersistentDeleteDeviceTaskManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Strategy class for an appropriate executable task recovery from persistent store
 */
class ExecutableTaskPersistentManager : PersistentTaskManagerProtocol {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func recoverTaskWithName(name: String) -> Executable {
        //TODO: Remove this with good value
        return DeleteDeviceExecutableTask(userId: 1, deviceId: 1)
    }
    
    func saveTaskWithName(name: String, type: ExecutableTaskType) {
        
    }
}