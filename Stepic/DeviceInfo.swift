//
//  DeviceInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import DeviceKit
import Foundation

final class DeviceInfo {
    static var current = DeviceInfo()

    private var currentDevice: DeviceKit.Device = DeviceKit.Device.current

    private init() { }

    var isPad: Bool {
        return self.currentDevice.isPad
    }

    var isPlus: Bool {
        return self.currentDevice.isOneOf(DeviceKit.Device.allPlusSizedDevices)
            || self.currentDevice.isOneOf(DeviceKit.Device.allPlusSizedDevices.map({ DeviceKit.Device.simulator($0) }))
    }

    var isXSerie: Bool {
        return self.currentDevice.isOneOf(DeviceKit.Device.allXSeriesDevices)
            || self.currentDevice.isOneOf(DeviceKit.Device.allSimulatorXSeriesDevices)
    }

    var OSVersion: (major: Int, minor: Int, patch: Int) {
        return (
            major: ProcessInfo.processInfo.operatingSystemVersion.majorVersion,
            minor: ProcessInfo.processInfo.operatingSystemVersion.minorVersion,
            patch: ProcessInfo.processInfo.operatingSystemVersion.patchVersion
        )
    }

    var diagonal: Double {
        return self.currentDevice.diagonal
    }

    var deviceInfoString: String {
        return "\(self.deviceModelString) \(self.deviceNameString) \(self.systemNameString) \(self.systemVersionString)"
    }

    var deviceModelString: String {
        return self.currentDevice.model ?? ""
    }

    var deviceNameString: String {
        return self.currentDevice.name ?? ""
    }

    var systemNameString: String {
        return self.currentDevice.systemName ?? ""
    }

    var systemVersionString: String {
        return self.currentDevice.systemVersion ?? ""
    }

    var orientation: (device: UIDeviceOrientation, interface: UIInterfaceOrientation) {
        return (device: UIDevice.current.orientation, interface: UIApplication.shared.statusBarOrientation)
    }
}
