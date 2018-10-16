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

    var didLaunch: Bool {
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

    fileprivate let startVersionKey = "startVersionKey"

    var startVersion: String {
        get {
            if let startVersion = defaults.value(forKey: startVersionKey) as? String {
                return startVersion
            } else {
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                self.startVersion = version
                return version
            }
        }

        set(value) {
            defaults.set(value, forKey: startVersionKey)
            defaults.synchronize()
        }
    }

}
