//
//  AdaptiveStorageManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AdaptiveStorageManager {
    static let shared = AdaptiveStorageManager()

    let defaults = UserDefaults.standard
    private let adaptiveModeKey = "useAdaptiveMode"

    var isAdaptiveModeEnabled: Bool {
        get {
            return defaults.bool(forKey: adaptiveModeKey)
        }
        set {
            defaults.set(newValue, forKey: adaptiveModeKey)
        }
    }
}
