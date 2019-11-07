//
//  LaunchDefaultsContainer.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class LaunchDefaultsContainer {
    private let defaults = UserDefaults.standard

    private let didLaunchKey = "didLaunchKey"

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

    private let startVersionKey = "startVersionKey"

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

    @discardableResult func initStartVersion() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        self.startVersion = version
        return version
    }
}
