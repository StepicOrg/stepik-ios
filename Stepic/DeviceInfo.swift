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
        #if os(iOS)
            return currentDevice.isPad
        #else
            return false
        #endif
    }

    var isPlus: Bool {
        #if os(iOS)
            return currentDevice.isOneOf(DeviceKit.Device.allPlusSizedDevices) ||
                   currentDevice.isOneOf(DeviceKit.Device.allPlusSizedDevices.map({ DeviceKit.Device.simulator($0) }))
        #else
            return false
        #endif
    }

    var OSVersion: (major: Int, minor: Int, patch: Int) {
        return (major: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
                minor: ProcessInfo.processInfo.operatingSystemVersion.minorVersion,
                patch: ProcessInfo.processInfo.operatingSystemVersion.patchVersion)
    }

    var diagonal: Double {
        #if os(iOS)
            return currentDevice.diagonal
        #else
            return 0
        #endif
    }

    var deviceInfoString: String {
        return "\(currentDevice.model) \(currentDevice.name) \(currentDevice.systemName) \(currentDevice.systemVersion)"
    }

    var deviceModelString: String {
        return currentDevice.model
    }

    #if os(iOS)
        var orientation: (device: UIDeviceOrientation, interface: UIInterfaceOrientation) {
            return (device: UIDevice.current.orientation, interface: UIApplication.shared.statusBarOrientation)
        }
    #endif
}
