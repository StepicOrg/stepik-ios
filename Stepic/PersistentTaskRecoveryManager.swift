//
//  PersistentTaskRecoveryManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Strategy class for recovering the task from store
 */
class PersistentTaskRecoveryManager {
    private init() {}
    static let sharedManager = PersistentTaskRecoveryManager()
    
    private func loadTaskObjectWithName(name: String) -> [String: AnyObject] {
        let path = NSBundle.mainBundle().bundlePath
        let scriptsPlistPath = "\(path)/Tasks.plist"
        let plistData = NSDictionary(contentsOfFile: scriptsPlistPath)!
        return plistData[name] as! [String: AnyObject]
    }
    
    func loadTaskWithName(name: String) -> Executable? {
        let object = loadTaskObjectWithName(name)
        let typeStringOrNil = object["type"] as? String
        let taskObjectOrNil = object["task"] as? [String: AnyObject]
        if let type = ExecutableTaskType(rawValue: typeStringOrNil ?? ""),
            taskObject = taskObjectOrNil {
            
            switch type {
            case .DeleteDevice: 
                return DeleteDeviceExecutableTaskSerializer.sharedSerializer.deserialize(dictionary: taskObject)
            }
            
        } else {
            return nil
        }
    }
}