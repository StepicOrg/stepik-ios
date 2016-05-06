//
//  PersistentTaskRecoveryManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Strategy class for recovering the correct task from store
 */
class PersistentTaskRecoveryManager {
    private init() {}
    static let sharedManager = PersistentTaskRecoveryManager()
    
    var plistPath : String {
        let path = NSBundle.mainBundle().bundlePath
        return "\(path)/Tasks.plist"
    }
    
    private func loadTaskObjectWithName(name: String) -> [String: AnyObject] {
        let plistData = NSDictionary(contentsOfFile: plistPath)!
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
                return DeleteDeviceExecutableTaskSerializer().deserialize(dictionary: taskObject) as? Executable
            }
            
        } else {
            return nil
        }
    }
    
    func writeTaskWithName(name: String, taskObject: [String: AnyObject], type: ExecutableTaskType) {
        let plistData = NSDictionary(contentsOfFile: plistPath)!
        plistData.setValue(taskObject, forKey: name)
        plistData.writeToFile(plistPath, atomically: true)
    }
}