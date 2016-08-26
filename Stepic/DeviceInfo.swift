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
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    }
    
    static var deviceInfoString : String {
        let d = UIDevice.currentDevice()
        return "\(d.model) \(d.name) \(d.systemName) \(d.systemVersion)"
    }
    
    static var deviceModelString: String {
        let d = UIDevice.currentDevice()
        return "\(d.model)"
    }
}