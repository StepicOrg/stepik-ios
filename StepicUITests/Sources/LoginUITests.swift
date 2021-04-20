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
        app.tap()
        // swiftlint:disable:next line_length
        if app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.staticTexts["Сменить аккаунт"]/*[[".otherElements[\"BrowserView?WebViewProcessID=73252\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"]",".links.matching(identifier: \"Сменить аккаунт\").staticTexts[\"Сменить аккаунт\"]",".staticTexts[\"Сменить аккаунт\"]",".webViews.webViews.webViews"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.waitForExistence(timeout: 5) {
            // swiftlint:disable:next line_length
            app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.staticTexts["Сменить аккаунт"]/*[[".otherElements[\"BrowserView?WebViewProcessID=73252\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"]",".links.matching(identifier: \"Сменить аккаунт\").staticTexts[\"Сменить аккаунт\"]",".staticTexts[\"Сменить аккаунт\"]",".webViews.webViews.webViews"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        }
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.textFields["Телефон или адрес эл. почты"]/*[[".otherElements[\"BrowserView?WebViewProcessID=71211\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"].textFields[\"Телефон или адрес эл. почты\"]",".textFields[\"Телефон или адрес эл. почты\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.textFields["Телефон или адрес эл. почты"]/*[[".otherElements[\"BrowserView?WebViewProcessID=71211\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"].textFields[\"Телефон или адрес эл. почты\"]",".textFields[\"Телефон или адрес эл. почты\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.typeText("stepik.qa4@gmail.com")
        app.tap()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.buttons["Далее"]/*[[".otherElements[\"BrowserView?WebViewProcessID=70062\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"].buttons[\"Далее\"]",".buttons[\"Далее\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.secureTextFields["Введите пароль"]/*[[".otherElements[\"BrowserView?WebViewProcessID=72282\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"].secureTextFields[\"Введите пароль\"]",".secureTextFields[\"Введите пароль\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.secureTextFields["Введите пароль"]/*[[".otherElements[\"BrowserView?WebViewProcessID=72282\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"].secureTextFields[\"Введите пароль\"]",".secureTextFields[\"Введите пароль\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.typeText("Qq1234567890Qq")
        app.tap()
        // swiftlint:disable:next line_length
        app/*@START_MENU_TOKEN@*/.webViews.webViews.webViews.buttons["Далее"]/*[[".otherElements[\"BrowserView?WebViewProcessID=72282\"].webViews.webViews.webViews",".otherElements[\"Вход – Google Аккаунты\"].buttons[\"Далее\"]",".buttons[\"Далее\"]",".webViews.webViews.webViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
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
