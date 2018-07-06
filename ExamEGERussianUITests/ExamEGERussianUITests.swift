//
//  ExamEGERussianUITests.swift
//  ExamEGERussianUITests
//
//  Created by jetbrains on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest

class ExamEGERussianUITests: XCTestCase {
    
    private var application: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        application = XCUIApplication()
        application.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
