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
    fileprivate let startVersionKey = "startVersionKey"
    fileprivate let isFirstSessionKey: String = "isFirstSessionKey"

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

    var startVersion: String {
        get {
            if let startVersion = defaults.value(forKey: startVersionKey) as? String {
                return startVersion
            } else {
                return initStartVersion()
            }
        }

        set(value) {
            defaults.set(value, forKey: startVersionKey)
        }
    }

    var isFirstSession: Bool {
        get {
            if let isFirstSession = defaults.value(forKey: isFirstSessionKey) as? Bool {
                return isFirstSession
            } else {
                return true
            }
        }

        set(value) {
            defaults.set(value, forKey: isFirstSessionKey)
        }
    }

    @discardableResult func initStartVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        self.startVersion = version
        return version
    }
}
