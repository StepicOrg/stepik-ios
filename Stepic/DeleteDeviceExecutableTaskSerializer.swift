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
    private init() {}
    static let sharedSerializer = DeleteDeviceExecutableTaskSerializer()
    
    func deserialize(dictionary dict: [String: AnyObject]) -> DeleteDeviceExecutableTask? {
        //TODO: Remove this with a good value
        let userId = dict["user"] as? Int
        let deviceId = dict["device"] as? Int
        if let user = userId,
            device = deviceId {
            let task = DeleteDeviceExecutableTask(userId: user, deviceId: device)
            return task
        } else {
            return nil
        }
    }
    
    func serialize(task task: DeleteDeviceExecutableTask) -> [String: AnyObject] {
        var res = [String: AnyObject]()
        res["user"] = task.userId
        res["device"] = task.deviceId
        return res
    }
}