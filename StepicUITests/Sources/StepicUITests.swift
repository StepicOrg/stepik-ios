import XCTest

class StepicUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false

        XCUIApplication().launchArguments += ["-AppleLanguages", "(en)"]
        XCUIApplication().launchArguments += ["-AppleLocale", "en_EN"]
    }

    override func tearDown() {
        XCUIApplication().terminate()
        super.tearDown()
    }

    func testApplicationCanStart() throws {
        let app = XCUIApplication()
        app.launch()
        app.terminate()
    }

    func testUserCanAllowNotificationsAfterCloseSplash() throws {
        // Adding Notification alert interruption
        self.addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { alert in
            let alertButton = alert.buttons["Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        Common.deleteMyApp()

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
        self.addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { alert in
            let alertButton = alert.buttons["Don’t Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        Common.deleteMyApp()

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
        self.addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { alert in
            let alertButton = alert.buttons["Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        Common.deleteMyApp()

        let app = XCUIApplication()
        app.launch()

        // Closing splash with cross
        app.navigationBars["Stepic.OnboardingView"].children(matching: .button).element.tap()

        // Waiting for language change button
        if app.scrollViews.otherElements.staticTexts["En"].waitForExistence(timeout: 5) {
            let elementsQuery = app.scrollViews.otherElements
            let enStaticText = elementsQuery.staticTexts["En"]
            // Set language to EN
            enStaticText.tap()
            // Set language to RU
            elementsQuery.buttons["Ru"].staticTexts["Ru"].tap()
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
            if app.scrollViews.otherElements.staticTexts["En"].waitForExistence(timeout: 5) {
                XCTFail("Language switcher still exists after restart")
            }
        } else {
            XCTFail("Language switcher not found")
        }
    }

    func testUnregisteredUserAllUI() throws {
        // Adding Notification alert interruption
        self.addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { alert in
            let alertButton = alert.buttons["Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        Common.deleteMyApp()
        let app = XCUIApplication()
        app.launch()
        // Closing splash with cross
        app.navigationBars["Stepic.OnboardingView"].children(matching: .button).element.tap()

        // Check all Catalog sections
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        app.tabBars["Tab Bar"].buttons["Catalog"].tap()
        XCTAssertTrue(
            elementsQuery.staticTexts["Editors' choice"].waitForExistence(timeout: 5),
            "No Editors choice section"
        )
        XCTAssertTrue(elementsQuery.staticTexts["Stepik trends"].exists, "No Stepik trends section")
        app.swipeUp()
        XCTAssertTrue(elementsQuery.staticTexts["Top categories"].exists, "No Top categories section")
        XCTAssertTrue(elementsQuery.staticTexts["Best authors"].exists, "No Best authors section")
        app.swipeUp()
        XCTAssertTrue(elementsQuery.staticTexts["Popular courses"].exists, "No Popular courses section")

        // Check all Home bar sections
        app.tabBars["Tab Bar"].buttons["Home"].tap()
        if app.scrollViews.otherElements.staticTexts["Enrolled"].waitForExistence(timeout: 5) {
            XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Enrolled"].exists, "No My courses section")
            XCTAssertTrue(app.scrollViews.otherElements.staticTexts["Popular"].exists, "No Popular section")
        } else {
            XCTFail("No Home bar elements")
        }

        // Check unsigned profile tab elements
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        if !app.buttons["Sign In"].staticTexts["Sign In"].waitForExistence(timeout: 10) {
            XCTFail("No Sign In button in profile tab")
        }

        // Check unsigned notification tab elements
        app.tabBars["Tab Bar"].buttons["Notifications"].tap()
        if !app.buttons["Sign In"].staticTexts["Sign In"].waitForExistence(timeout: 10) {
            XCTFail("No Sign In button in notifications tab")
        }

        app.terminate()
    }

    func testUserCanRegister() throws {
        // Adding Notification alert interruption
        self.addUIInterruptionMonitor(withDescription: "“Stepik” Would Like to Send You Notifications") { alert in
            let alertButton = alert.buttons["Allow"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        // We need clean installation for this test
        Common.deleteMyApp()
        let timestamp = Int64(Date().timeIntervalSince1970)
        let app = XCUIApplication()
        app.launch()
        // Closing splash with cross
        app.navigationBars["Stepic.OnboardingView"].children(matching: .button).element.tap()
        // Register new user
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        if !app.buttons["Sign In"].staticTexts["Sign In"].waitForExistence(timeout: 10) {
            XCTFail("No Sign In button in profile tab")
        } else {
            app.buttons["Sign In"].staticTexts["Sign In"].tap()
            app.buttons["Sign Up"].tap()
            app.textFields["Name"].tap()
            app.textFields["Name"].typeText("ios_autotest_\(timestamp)")
            app.textFields["Email"].tap()
            Common.pasteTextFieldText(app: app, element: app.textFields["Email"], value: "ios_autotest_\(timestamp)@stepik.org", clearText: false)
            app.secureTextFields["Password"].tap()
            sleep(5)
            Common.pasteTextFieldText(
                app: app,
                element: app.secureTextFields["Password"],
                value: kcurrentUserPwd,
                clearText: false
            )
            app.buttons["Register"].tap()
        }
        // Check user profile loaded
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        let elementsQuery = app.scrollViews.otherElements
        if elementsQuery.staticTexts["ios_autotest_\(timestamp)"].waitForExistence(timeout: 5) {
            XCTAssertTrue(elementsQuery.staticTexts["Activity"].exists, "No Activity section")
            XCTAssertTrue(elementsQuery.staticTexts["Achievements"].exists, "No Achievements section")
        }
        app.terminate()
    }
    func testUserCanLogIn() throws {
        let app = XCUIApplication()
        app.launch()
        if Common.userLoggedIn(app: app) {
            Common.logOut(app: app)
        }
        Common.setUser()
        app.launch()
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.buttons["Sign In"].staticTexts["Sign In"].tap()
        app.buttons["Sign In with e-mail"].tap()
        app.textFields["Email"].tap()
        Common.pasteTextFieldText(app: app, element: app.textFields["Email"], value: currentUserEmail, clearText: false)
        app.secureTextFields["Password"].tap()
        sleep(5)
        Common.pasteTextFieldText(
            app: app,
            element: app.secureTextFields["Password"],
            value: kcurrentUserPwd,
            clearText: false
        )
        app.buttons["Log in"].tap()
        // Check user profile loaded
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        let elementsQuery = app.scrollViews.otherElements
        if elementsQuery.staticTexts[currentUserName].waitForExistence(timeout: 5) {
            XCTAssertTrue(elementsQuery.staticTexts["Activity"].exists, "No Activity section")
            XCTAssertTrue(elementsQuery.staticTexts["Achievements"].exists, "No Achievements section")
        }
        app.terminate()
    }
    func testUserCanLogout() throws {
        let app = XCUIApplication()
        app.launch()
        if !Common.userLoggedIn(app: app) {
            Common.logIn(app: app)
        }
        Common.logOut(app: app)
        if Common.userLoggedIn(app: app) {
            XCTFail("User was not logged out")
        }
        app.terminate()
    }
    //    func testLaunchPerformance() throws {
    //        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
    //            // This measures how long it takes to launch your application.
    //            measure(metrics: [XCTApplicationLaunchMetric()]) {
    //                XCUIApplication().launch()
    //            }
    //        }
    //    }
}
