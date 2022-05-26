//
//  ProfileScreen.swift
//  StepicUITests
//
//  Created by admin on 19.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class ProfileScreen: BaseScreen {

    public lazy var btnSingIn = app.buttons["loginButton"]
    private lazy var btnSettings = app.buttons["settingsButton"]
    private lazy var btnLogOut = app.tables.cells["logOut"]
    
    func clickSingIn() {
        XCTAssertTrue(btnSingIn.waitForExistence(timeout: 10), "No Login button")
        btnSingIn.tap()
    }
    
    func openSettings() -> ProfileScreen {
        XCTAssertTrue(btnSettings.waitForExistence(timeout: 10), "No Settings button")
        btnSettings.tap()
        return self
    }
    
    func logOut() {
        app.swipeUp()
        btnLogOut.tap()
        confirmAlert(text: "Выйти", button: "Выйти")
    }
    
    func shouldBeUserProfile(name: String) {
        shouldBeText(text: name)
    }
    
    func shouldBeSingInButton() {
        XCTAssertTrue(btnSingIn.waitForExistence(timeout: 10), "No Login button")
    }
    
}
