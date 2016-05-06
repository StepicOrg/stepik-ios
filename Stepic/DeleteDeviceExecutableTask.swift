//
//  DeleteDeviceExecutableTask.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 ExecutableTask for deleting device on the server 
 */
class DeleteDeviceExecutableTask : Executable, DictionarySerializable {
    
    init(userId: Int, deviceId: Int) {
        self.userId = userId
        self.deviceId = deviceId
    }
    
    convenience required init?(dictionary dict: [String: AnyObject]) {
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
            self.init(userId: user, deviceId: device)
        } else {
            return nil
        }
    }
    
    func serializeToDictionary() -> [String : AnyObject] {
        let res : [String: AnyObject] = 
            [
                "type" : type.rawValue, 
                "task": [
                    "user" : userId,
                    "device" : deviceId
                ]
            ]
            
        return res
    }

    
    var type : ExecutableTaskType {
        return .DeleteDevice
    }
    
    var userId : Int
    var deviceId : Int
    
    var description: String {
        return "\(type.rawValue) \(userId) \(deviceId)"
    }
    
    func execute(success success: (Void -> Void), failure: (Void -> Void)) {
        
    }
}