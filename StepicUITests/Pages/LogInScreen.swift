//
//  LogInScreen.swift
//  StepicUITests
//
//  Created by admin on 19.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class LogInScreen: BaseScreen {

    private lazy var fieldEmail = app.textFields[AccessibilityIdentifiers.AuthEmail.emailTextField]
    private lazy var fieldPassword = app.secureTextFields[AccessibilityIdentifiers.AuthEmail.passwordTextField]
    private lazy var btnLogIn = app.buttons[AccessibilityIdentifiers.AuthEmail.logInButton]
    
    func fillUserInfo(email: String, password: String) -> LogInScreen {
        typeText(element: fieldEmail, value: email)
        typeText(element: fieldPassword, value: password)
        return self
    }
    
    func clickLogIn() {
        XCTAssertTrue(btnLogIn.waitForExistence(timeout: 10), "No 'Log in' button")
        btnLogIn.tap()
    }
    
}
