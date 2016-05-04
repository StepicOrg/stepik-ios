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
class DeleteDeviceExecutableTaskSerializer {
    func deserialize(dictionary dict: [String: AnyObject]) -> DeleteDeviceExecutableTask {
        //TODO: Remove this with a good value
        return DeleteDeviceExecutableTask(userId: 1, deviceId: 1)
    }
    
    func serialize(task task: DeleteDeviceExecutableTask) -> [String: AnyObject] {
        var res = [String: AnyObject]()
        return res
    }
}