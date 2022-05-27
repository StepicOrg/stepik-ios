//
//  AuthScreen.swift
//  StepicUITests
//
//  Created by admin on 25.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class AuthScreen: BaseScreen {

    private lazy var btnLoginWithEmail = app.buttons[AccessibilityIdentifiers.AuthSocial.signInButton]
    private lazy var btnRegister = app.buttons[AccessibilityIdentifiers.AuthSocial.signUpButton]
    private lazy var btnGoogle = app.collectionViews.children(matching: .cell).element(boundBy: 2)
    
    func shouldBeAuthScreen() {
        XCTAssertTrue(btnLoginWithEmail.waitForExistence(timeout: 10), "No 'Log in with email' button")
        XCTAssertTrue(btnRegister.waitForExistence(timeout: 10), "No 'Register' button")
    }
    
    func clickRegister() {
        XCTAssertTrue(btnRegister.waitForExistence(timeout: 10), "No 'Register' button")
        btnRegister.tap()
    }
    
    func clickLoginWithEmail() {
        XCTAssertTrue(btnLoginWithEmail.waitForExistence(timeout: 10), "No 'Log in with email' button")
        btnLoginWithEmail.tap()
    }
    
    func clickLogInWithGoogle() {
        XCTAssertTrue(btnGoogle.waitForExistence(timeout: 10), "No 'Google' button")
        btnGoogle.tap()
        
    }
    
}
