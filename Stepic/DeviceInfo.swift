//
//  DeviceInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct DeviceInfo {
    static func isIPad() -> Bool {
        #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        #else
            return false
        #endif
    }

    static var deviceInfoString: String {
        #if os(iOS)
            let d = UIDevice.current
            return "\(d.model) \(d.name) \(d.systemName) \(d.systemVersion)"
        #else
            return "tvos"
        #endif

    }

    static var deviceModelString: String {
        #if os(iOS)
            let d = UIDevice.current
            return "\(d.model)"
        #else
            return "tvos"
        #endif

    }
}
