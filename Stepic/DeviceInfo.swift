//
//  DeviceInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

struct DeviceInfo {
    static func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    static var deviceInfoString : String {
        let d = UIDevice.current
        return "\(d.model) \(d.name) \(d.systemName) \(d.systemVersion)"
    }
    
    static var deviceModelString: String {
        let d = UIDevice.current
        return "\(d.model)"
    }
}
