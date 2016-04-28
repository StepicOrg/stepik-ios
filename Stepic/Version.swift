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
    var url: NSURL
    init(version: String, url: NSURL) {
        self.version = version
        self.url = url
    }
}