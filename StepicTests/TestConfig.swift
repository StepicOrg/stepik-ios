//
//  TestConfig.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class TestConfig {
    
    static let sharedConfig = TestConfig()
    
    private init() {
        let bundle = Bundle(for: type(of: self) as AnyClass)
        if let path = bundle.path(forResource: "TestInfo", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String: Any] {
                print(dic)
                if let login = dic["login"] as? [String: Any] {
                    username = login["name"] as? String ?? ""
                    password = login["password"] as? String ?? ""
                }
            }
        }
    }
    
    var username = ""
    var password = ""
}
