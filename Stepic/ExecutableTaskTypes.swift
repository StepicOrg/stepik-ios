//
//  ExecutableTaskTypes.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Enum, which contains executable tasks types
 */
enum ExecutableTaskType : String {
    case deleteDevice = "deleteDeviceTask"
    case postViews = "postViewsTask"
    static let allValues = [deleteDevice, postViews]
}
