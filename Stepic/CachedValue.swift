//
//  CachedValue.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation

class CachedValue<T> {
    private let defaults = UserDefaults.standard

    private let key: String

    private var privateValue: T?
    private var defaultValue: T

    var value: T {
        get {
            if privateValue == nil {
                privateValue = defaults.value(forKey: key) as? T
            }
            return privateValue ?? defaultValue
        }
        set {
            defaults.set(newValue, forKey: key)
            privateValue = newValue
        }
    }

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    convenience init(key: String, value: T, defaultValue: T) {
        self.init(key: key, defaultValue: defaultValue)
        self.value = value
    }
}
