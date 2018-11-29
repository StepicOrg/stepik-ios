//
//  UserDefaults+StringStorageServiceProtocol.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation

extension UserDefaults: StringStorageServiceProtocol {
    func save(string: String?, for key: String) {
        self.set(string, forKey: key)
    }

    func getString(for key: String) -> String? {
        return self.object(forKey: key) as? String
    }
}
