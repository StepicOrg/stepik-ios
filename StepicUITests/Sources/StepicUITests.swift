//
//  StepicUITests.swift
//  StepicUITests
//
//  Created by AKholin on 11.03.2021.
//  Copyright © 2021 Alex Karpov. All rights reserved.
//

import XCTest

class StepicUITests: XCTestCase {
    

    override func setUpWithError() throws {
        // This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        XCUIApplication().launchArguments += ["-AppleLanguages", "(en)"]
        XCUIApplication().launchArguments += ["-AppleLocale", "en_EN"]
    }

    override func tearDownWithError() throws {
        // This method is called after the invocation of each test method in the class.
        XCUIApplication().terminate()
        super.tearDown()
    }


    func deleteMyApp() {
        let appName = "Stepik"

        // Put the app in the background
        //XCUIDevice.shared.press(XCUIDevice.Button.home)

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.icons[appName].waitForExistence(timeout: 5) {
            springboard.icons[appName].press(forDuration: 1.5);
        }

        if springboard.collectionViews.buttons["Remove App"].waitForExistence(timeout: 5) {
            springboard.collectionViews.buttons["Remove App"].tap()
        }

        if springboard.alerts["Remove “\(appName)”?"].scrollViews.otherElements.buttons["Delete App"].waitForExistence(timeout: 5) {
            springboard.alerts["Remove “\(appName)”?"].scrollViews.otherElements.buttons["Delete App"].tap()
        }

        if springboard.alerts["Delete “\(appName)”?"].scrollViews.otherElements.buttons["Delete"].waitForExistence(timeout: 5) {
            springboard.alerts["Delete “\(appName)”?"].scrollViews.otherElements.buttons["Delete"].tap()
        }
        }
    
    func testApplicationCanStart() throws {
        let app = XCUIApplication()
        app.launch()
        app.terminate()
    }
    
    func testUserCanAllowNotificationsAfterCloseSplash() throws {
        // Adding Notification alert interruption
        addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { (alert) -> Bool in
            let alertButton = alert.buttons["Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        deleteMyApp()
        
        let app = XCUIApplication()
        app.launch()
        
        // Closing splash with cross
        app.navigationBars["Stepic.OnboardingView"].children(matching: .button).element.tap()
        
        // Allowing notifications alert
        app.tap()
        
        // Waiting for Editors choice text
        if app.scrollViews.otherElements.staticTexts["Editors' choice"].waitForExistence(timeout: 5) {
        XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Editors' choice"].exists)
        }
        app.terminate()
    }
    
    func testUserCanDisallowNotificationsAfterFinishingSplash() throws {
        // Adding Notification alert interruption
        addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { (alert) -> Bool in
            let alertButton = alert.buttons["Don’t Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        deleteMyApp()
        
        let app = XCUIApplication()
        app.launch()
        
        // Finishing splash
        let elementsQuery = app.scrollViews.otherElements
        let button = elementsQuery.buttons["Next"]
        button.tap()
        button.tap()
        button.tap()
        elementsQuery.buttons["Start"].tap()
        
        // Allowing notifications alert
        app.tap()
        
        // Waiting for Editors choice text
        if app.scrollViews.otherElements.staticTexts["Editors' choice"].waitForExistence(timeout: 5) {
        XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Editors' choice"].exists)
        }
    }
    
    func testUserCanChangeLanguageOnce() throws {
        // Adding Notification alert interruption
        addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { (alert) -> Bool in
            let alertButton = alert.buttons["Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        deleteMyApp()
        
        let app = XCUIApplication()
        app.launch()
        
        // Closing splash with cross
        app.navigationBars["Stepic.OnboardingView"].children(matching: .button).element.tap()
        
        // Waiting for language change button
        
        if app.scrollViews.otherElements/*@START_MENU_TOKEN@*/.staticTexts["En"]/*[[".buttons[\"En\"].staticTexts[\"En\"]",".staticTexts[\"En\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5) {
            let elementsQuery = app.scrollViews.otherElements
            let enStaticText = elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["En"]/*[[".buttons[\"En\"].staticTexts[\"En\"]",".staticTexts[\"En\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        // Set language to EN
            enStaticText.tap()
        // Set language to RU
            elementsQuery/*@START_MENU_TOKEN@*/.buttons["Ru"].staticTexts["Ru"]/*[[".buttons[\"Ru\"].staticTexts[\"Ru\"]",".staticTexts[\"Ru\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        // Check Russian language enabled
            if elementsQuery.staticTexts["Stepik рекомендует 👍"].waitForExistence(timeout: 5) {
        // Set language to EN
                    enStaticText.tap()
        // Check english language enabled
                    if !elementsQuery.staticTexts["Editors' choice"].waitForExistence(timeout: 5) {
                        XCTFail()
                }
          }
        // Restart app
        app.terminate()
        app.launch()
        
        // Check for language change button abstance
        if app.scrollViews.otherElements/*@START_MENU_TOKEN@*/.staticTexts["En"]/*[[".buttons[\"En\"].staticTexts[\"En\"]",".staticTexts[\"En\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5) {
            XCTFail("Language switcher still exists after restart")
        }

        } else {
            XCTFail("Language switcher not found")
         }
        }
    
    func testUnregisteredUserAllUI() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Check all Catalog sections
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements

        XCTAssertTrue(elementsQuery.staticTexts["Editors' choice"].exists,"No Editors choice section")
        XCTAssertTrue(elementsQuery.staticTexts["Stepik trends"].exists,"No Stepik trends section")
        app.swipeUp()
        XCTAssertTrue(elementsQuery.staticTexts["Top categories"].exists,"No Top categories section")
        XCTAssertTrue(elementsQuery.staticTexts["Best authors"].exists,"No Best authors section")
        app.swipeUp()
        XCTAssertTrue(elementsQuery.staticTexts["Popular courses"].exists,"No Popular courses section")

        // Check all Home bar sections
        app.tabBars["Tab Bar"].buttons["Home"].tap()
        if app.scrollViews.otherElements.staticTexts["Enrolled"].waitForExistence(timeout: 5) {
        XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Enrolled"].exists,"No My courses section")
        XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Popular"].exists,"No Popular section")
        } else {XCTFail("No Home bar elements")}
        
        // Check unsigned profile tab elements
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        
        if !app/*@START_MENU_TOKEN@*/.buttons["Sign In"].staticTexts["Sign In"]/*[[".buttons[\"Sign In\"].staticTexts[\"Sign In\"]",".staticTexts[\"Sign In\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 10) {
                XCTFail("No Sign In button in profile tab")
        }
        
        // Check unsigned notification tab elements
        app.tabBars["Tab Bar"].buttons["Notifications"].tap()
        if !app/*@START_MENU_TOKEN@*/.buttons["Sign In"].staticTexts["Sign In"]/*[[".buttons[\"Sign In\"].staticTexts[\"Sign In\"]",".staticTexts[\"Sign In\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 10) {
                XCTFail("No Sign In button in notifications tab")
        }
        app.terminate()
    }

    /*func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
      } */
}
