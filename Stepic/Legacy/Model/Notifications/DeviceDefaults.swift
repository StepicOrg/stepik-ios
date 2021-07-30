//
//  DeviceDefaults.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Stores and manages information about device defaults
 */
@available(*, deprecated, message: "Legacy class")
final class DeviceDefaults {
    private init() {}

    static let sharedDefaults = DeviceDefaults()

    private let defaults = UserDefaults.standard
    private let deviceIdKey = "nofiticationsDeviceId"

    var deviceId: Int? {
        get {
            defaults.value(forKey: deviceIdKey) as? Int
        }
        set(id) {
            defaults.setValue(id, forKey: deviceIdKey)
            defaults.synchronize()
        }
    }
}
