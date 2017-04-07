//
//  LaunchDefaultsContainer.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class LaunchDefaultsContainer {
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate let didLaunchKey = "didLaunchKey"
    
    var didLaunch : Bool {
        get {
            if let did = defaults.value(forKey: didLaunchKey) as? Bool {
                return did
            } else {
                return false
            }
        }
        
        set(value) {
            defaults.set(value, forKey: didLaunchKey)
            defaults.synchronize()
        }
    }
}
