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
    
    init(key: String) {
        self.key = key
    }
    
    init(key: String, value: T?) {
        self.key = key
        self.value = value
    }
    
    private var privateValue: T?
    
    var value: T? {
        get {
            if privateValue == nil {
                privateValue = defaults.value(forKey: key) as? T
            }
            return privateValue
        }
        set {
            defaults.set(newValue, forKey: key)
            privateValue = newValue
        }
    }
}
