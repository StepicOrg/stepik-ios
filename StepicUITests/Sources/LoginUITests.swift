import XCTest

class LoginUITests: XCTestCase {
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

    func testUserCanLogInWithEmail() throws {
        let app = XCUIApplication()
        app.launch()

        if Common.isUserLoggedIn(app: app) {
            Common.logOut(app: app)
        }

        Common.registerNewUserIfNeeded()

        app.launch()
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.buttons["Sign In"].staticTexts["Sign In"].tap()
        app.buttons["Sign In with e-mail"].tap()

        app.textFields["Email"].tap()
        sleep(2)
        Common.pasteTextFieldText(
            app: app,
            element: app.textFields["Email"],
            value: currentUserEmail
        )

        app.secureTextFields["Password"].tap()
        sleep(2)
        Common.pasteTextFieldText(
            app: app,
            element: app.secureTextFields["Password"],
            value: kCurrentUserPassword
        )

        app.buttons["Log in"].tap()
        // Check user profile loaded
        if app.tabBars["Tab Bar"].buttons["Profile"].waitForExistence(timeout: 5) {
            app.tabBars["Tab Bar"].buttons["Profile"].tap()
        }

        let elementsQuery = app.scrollViews.otherElements

        if elementsQuery.staticTexts[currentUserName].waitForExistence(timeout: 5) {
            XCTAssertTrue(elementsQuery.staticTexts["Activity"].exists, "No Activity section")
            XCTAssertTrue(elementsQuery.staticTexts["Achievements"].exists, "No Achievements section")
        } else {
            XCTFail("User could not login")
        }

        app.terminate()
    }

    func testUserCanLogInWithGoogle() throws {
        // Adding Notification alert interruption
        self.addUIInterruptionMonitor(withDescription: "“Stepik” Wants to Use “google.com” to Sign In") { alert in
            let alertButton = alert.buttons["Continue"]
            if alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
        let app = XCUIApplication()
        app.launch()
        if Common.isUserLoggedIn(app: app) {
            Common.logOut(app: app)
        }
        app.launch()
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.buttons["Sign In"].staticTexts["Sign In"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 2).tap()
        if app.webViews.webViews.webViews.staticTexts["Сменить аккаунт"].waitForExistence(timeout: 1) {
            app.webViews.webViews.webViews.staticTexts["Сменить аккаунт"].tap()
        }
        app.tap()
        app.webViews.webViews.webViews.textFields["Телефон или адрес эл. почты"].tap()
        app.webViews.webViews.webViews.textFields["Телефон или адрес эл. почты"].typeText("stepik.qa4@gmail.com")
        app.tap()
        app.webViews.webViews.webViews.buttons["Далее"].tap()
        app.webViews.webViews.webViews.secureTextFields["Введите пароль"].tap()
        app.webViews.webViews.webViews.secureTextFields["Введите пароль"].typeText("Qq1234567890Qq")
        app.tap()
        app.webViews.webViews.webViews.buttons["Далее"].tap()
        if !Common.isUserLoggedIn(app: app) {
            XCTFail("Login with google account failed")
        }
    }

    func testUserCanLogout() throws {
        let app = XCUIApplication()
        app.launch()

        if !Common.isUserLoggedIn(app: app) {
            Common.registerNewUserIfNeeded()
            app.launch()
            Common.logIn(app: app)
        }

        Common.logOut(app: app)

        if Common.isUserLoggedIn(app: app) {
            XCTFail("User was not logged out")
        }

        app.terminate()
    }
}
