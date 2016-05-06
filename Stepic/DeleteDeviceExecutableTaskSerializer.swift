//
//  DeleteDeviceExecutableTaskSerializer.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
 Serializes DeleteDeviceExecutableTask object
 */
class DeleteDeviceExecutableTaskSerializer : DictionarySerializer {
    
    func deserialize(dictionary dict: [String : AnyObject]) -> AnyObject? {
        let taskDict = dict["task"] as? [String: AnyObject]
        let typeString = dict["type"] as? String
        let userId = taskDict?["user"] as? Int
        let deviceId = taskDict?["device"] as? Int
        if let user = userId,
            device = deviceId,
            typeS = typeString
        {
            if ExecutableTaskType(rawValue: typeS) != ExecutableTaskType.DeleteDevice {
                return nil
            }
            let task = DeleteDeviceExecutableTask(userId: user, deviceId: device)
            return task
        } else {
            return nil
        }
    }
    
    func serialize(object: AnyObject) -> [String : AnyObject]? {
        if let task = object as? DeleteDeviceExecutableTask {
            
            if task.type != ExecutableTaskType.DeleteDevice {
                return nil
            }
            
            let res : [String: AnyObject] = 
            [
                "type" : task.type.rawValue, 
                "task": [
                    "user" : task.userId,
                    "device" : task.deviceId
                ]
            ]
            
            return res
        } else {
            return nil
        }
    }
}