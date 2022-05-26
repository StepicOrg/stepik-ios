//
//  RegisterScreen.swift
//  StepicUITests
//
//  Created by admin on 23.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class RegisterScreen: BaseScreen {

    private lazy var fieldName = app.textFields["nameTextField"]
    private lazy var fieldEmail = app.textFields["emailTextField"]
    private lazy var fieldPassword = app.secureTextFields["passwordTextField"]
    private lazy var btnRegister = app.buttons["registerButton"]
    
    func fillUserInfo(name: String, email: String, password: String) -> RegisterScreen {
        typeText(element: fieldName, value: name)
        typeText(element: fieldEmail, value: email)
        typeText(element: fieldPassword, value: password)
        return self
    }
    
    func clickRegister() {
        XCTAssertTrue(btnRegister.waitForExistence(timeout: 10), "No Register button")
        btnRegister.tap()
    }
    
}
