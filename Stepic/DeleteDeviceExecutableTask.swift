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
class DeleteDeviceExecutableTask : Executable {
    
    var type : ExecutableTaskType {
        return .DeleteDevice
    }
    
    var userId : Int
    var deviceId : Int
    
    var description = {
        return "\(1)"
    }
    
    init(userId: Int, deviceId: Int) {
        self.userId = userId
        self.deviceId = deviceId
    }
    
    func execute(success success: (Void -> Void), failure: (Void -> Void)) {
        
    }
}