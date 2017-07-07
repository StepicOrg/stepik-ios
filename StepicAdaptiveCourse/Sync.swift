//
//  Sync.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CloudKit

class Sync {
    typealias AccountCredentials = (email: String?, password: String?)
    
    static let shared = Sync()
    
    private let emailKey = "email"
    private let passwordKey = "password"
    
    private let keyStore: NSUbiquitousKeyValueStore!
    
    init() {
        keyStore = NSUbiquitousKeyValueStore()
    }
    
    @discardableResult func saveAccountCredentials(email: String, password: String) -> Bool {
        keyStore.set(email, forKey: emailKey)
        keyStore.set(password, forKey: passwordKey)
        let result = keyStore.synchronize()
        print("saving account, status = \(result)")
        
        return result
    }
    
    func restoreAccountCredentials() -> AccountCredentials {
        let email = keyStore.string(forKey: emailKey)
        let password = keyStore.string(forKey: passwordKey)
        print("restored account: \(email ?? "<empty>"), \(password ?? "<empty>")")
        
        return (email: email, password: password)
    }
    
    @discardableResult func clearCredentials() -> Bool {
        keyStore.removeObject(forKey: emailKey)
        keyStore.removeObject(forKey: passwordKey)
        
        let result = keyStore.synchronize()
        print("clear account, status = \(result)")
        
        return result
    }
}
