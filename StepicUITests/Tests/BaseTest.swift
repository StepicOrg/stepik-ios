//
//  BaseTest.swift
//  StepicUITests
//
//  Created by admin on 26.04.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

open class BaseTest: XCTestCase {
    
    private var baseScreen = BaseScreen()
//
//    public enum Constants {
//
//        public static let defaultWaitTime = 10.0
//    }

    lazy var app = baseScreen.app
    
    open override func setUp() {
        continueAfterFailure = false
        app.launchArguments += ["-AppleLanguages", "(ru)"]
        app.launchArguments += ["-AppleLocale", "ru_RU"]
        app.launch()
    }

    open override func tearDown() {
        app.terminate()
    }
}
