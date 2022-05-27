//
//  UnregisteredUserTests.swift
//  StepicUITests
//
//  Created by admin on 26.04.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

import Foundation
import XCTest

class OnboardingTests: BaseTest {
    
    let onbordingScreen = OnboardingScreen()
    let navigation = MainNavigationTabs()
    let authScreen = AuthScreen()
    let profileScreen = ProfileScreen()
    
    override func setUp() {
        deleteApplication()
        super.setUp()
        
        addUIInterruptionMonitor(
            withDescription: "“\(AppName.name)” Would Like to Send You Notifications"
        ) { alert -> Bool in
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
    
    func testUserCanFollowOnboarding() throws {
        onbordingScreen
            .next()
            .next()
            .next()
            .next()
        app.tap()
        authScreen.shouldBeAuthScreen()
    }
    
    func testUserCanCloseOnboarding() throws {
        onbordingScreen.closeOnbording()
        app.tap()
        navigation.openProfile()
        profileScreen.shouldBeSingInButton()
    }

}
