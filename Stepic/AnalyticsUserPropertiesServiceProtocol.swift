//
//  ABAnalyticsServiceProtocol.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation

protocol ABAnalyticsServiceProtocol {
    func reportOnce(test: String, group: String)
}
