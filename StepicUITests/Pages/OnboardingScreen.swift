//
//  OnboardingScreen.swift
//  StepicUITests
//
//  Created by admin on 26.04.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class OnboardingScreen: BaseScreen {

    private lazy var btnCloseOnbording = app.navigationBars.buttons["closeOnbordingButton"]
    private lazy var btnNext = app.buttons["nextButton"]
    

    func closeOnbording() {
        XCTAssertTrue(btnCloseOnbording.waitForExistence(timeout: 10), "No Close button")
        btnCloseOnbording.tap()
    }
    
    func next() -> OnboardingScreen {
        XCTAssertTrue(btnNext.waitForExistence(timeout: 10), "No Next button")
        btnNext.tap()
        return self
    }
    
}
