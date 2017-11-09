//
//  DeviceInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import DeviceKit

class DeviceInfo {
    static var current = DeviceInfo()

    private var currentDevice: DeviceKit.Device = DeviceKit.Device()

    private init() { }

    var isPad: Bool {
        return currentDevice.isPad
    }

    var diagonal: Double {
        return currentDevice.diagonal
    }

    var deviceInfoString: String {
        return "\(currentDevice.model) \(currentDevice.name) \(currentDevice.systemName) \(currentDevice.systemVersion)"
    }

    var deviceModelString: String {
        return currentDevice.model
    }
}
