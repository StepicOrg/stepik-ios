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

    var isPlus: Bool {
        return currentDevice.isOneOf(DeviceKit.Device.allPlusSizedDevices) ||
               currentDevice.isOneOf(DeviceKit.Device.allPlusSizedDevices.map({ DeviceKit.Device.simulator($0) }))
    }

    var OSVersion: (major: Int, minor: Int, patch: Int) {
        return (major: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
                minor: ProcessInfo.processInfo.operatingSystemVersion.minorVersion,
                patch: ProcessInfo.processInfo.operatingSystemVersion.patchVersion)
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

    var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
}
