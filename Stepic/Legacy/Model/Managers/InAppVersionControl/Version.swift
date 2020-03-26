//
//  Version.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Struct, which contains application version info
 */
struct Version {
    var version: String
    var url: URL
    init(version: String, url: URL) {
        self.version = version
        self.url = url
    }
}
