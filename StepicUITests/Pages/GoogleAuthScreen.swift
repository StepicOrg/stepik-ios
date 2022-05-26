//
//  GoogleAuthScreen.swift
//  StepicUITests
//
//  Created by admin on 25.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class GoogleAuthScreen: BaseScreen {
    
    private lazy var textChangeAccount = app.webViews.webViews.webViews.staticTexts["Сменить аккаунт"]
    private lazy var fieldEmail = app.webViews.webViews.webViews.textFields.element(boundBy: 0)
    private lazy var fieldPassword = app.webViews.webViews.webViews.secureTextFields.element(boundBy: 0)
    private lazy var btnNext = app.webViews.webViews.webViews.buttons["Далее"]

    
    func singIn(email: String, password: String) {
        if textChangeAccount.waitForExistence(timeout: 1) {
            textChangeAccount.tap()
        }
        app.tap()
        typeText(element: fieldEmail, value: email)
        app.tap()
        btnNext.tap()
        typeText(element: fieldPassword, value: password)
        app.tap()
        btnNext.tap()
        // next step is to verify account, need to reseach how work with it
    }
}
