//
//  RegisterTests.swift
//  StepicUITests
//
//  Created by admin on 23.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class RegisterTests: BaseTest {
    
    let onbordingScreen = OnboardingScreen()
    let navigation = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    let authScreen = AuthScreen()
    let registerScreen = RegisterScreen()

    override func setUp() {
        deleteApplication()
        super.setUp()
        
        addUIInterruptionMonitor(withDescription: "“Stepik Release” Would Like to Send You Notifications") { alert -> Bool in
            let alertButton = alert.buttons["Allow"]
            if alert.elementType == .alert && alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testUserCanRegister() throws {
        let ts = String(Int64(Date().timeIntervalSince1970))
        let name = "Bot_\(ts)"
        let email = "ios_autotest_\(ts)@stepik.org"
        
        onbordingScreen.closeOnbording()
        app.tap()
        navigation.openProfile()
        profileScreen.clickSingIn()
        authScreen.clickRegister()
        registerScreen
            .fillUserInfo(name: name, email: email, password: ts)
            .clickRegister()
        profileScreen.shouldBeUserProfile(name: name)
    }
}
