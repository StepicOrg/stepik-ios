import Foundation
import XCTest

var currentUserName: String = "test"
var currentUserEmail: String = "test"
let kcurrentUserPwd = "512"


enum Common {
    static func setUser() -> Bool {
        if currentUserEmail.contains("ios_autotest") {
            return false
        }
        let timestamp = Int64(Date().timeIntervalSince1970)
        currentUserName = "ios_autotest_\(timestamp)"
        currentUserEmail = "ios_autotest_\(timestamp)@stepik.org"

        // register new user
        let app = XCUIApplication()
        app.launch()

        // Register new user
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        if !app.buttons["Sign In"].staticTexts["Sign In"].waitForExistence(timeout: 5) {
            XCTFail("No Sign In button in profile tab")
        } else {
            app.buttons["Sign In"].staticTexts["Sign In"].tap()
            app.buttons["Sign Up"].tap()
            app.textFields["Name"].tap()
            app.textFields["Name"].typeText(currentUserName)
            app.textFields["Email"].tap()
            Common.pasteTextFieldText(
                app: app,
                element: app.textFields["Email"],
                value: currentUserEmail,
                clearText: false
            )
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
        logOut(app: app)
        app.terminate()
        return true
    }

    static func userLoggedIn(app: XCUIApplication) -> Bool {
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        if app.buttons["Sign In"].staticTexts["Sign In"].waitForExistence(timeout: 10) {
            return false
        }
        return true
    }

    static func logOut(app: XCUIApplication) {
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        app.navigationBars["Profile"].buttons["settings"].tap()
        app.swipeUp()
        app.tables.staticTexts["Log Out"].tap()
        app.alerts["Log Out"].scrollViews.otherElements.buttons["Log Out"].tap()
        if !app.buttons["Sign In"].staticTexts["Sign In"].waitForExistence(timeout: 10) {
        XCTFail("Logout failed")
        }
    }
    static func logIn(app: XCUIApplication) {
        app.buttons["Sign In"].staticTexts["Sign In"].tap()
        app.buttons["Sign In with e-mail"].tap()
        Common.pasteTextFieldText(
            app: app,
            element: app.textFields["Email"],
            value: currentUserEmail,
            clearText: false
        )
        app.secureTextFields["Password"].tap()
        sleep(5)
        Common.pasteTextFieldText(
            app: app,
            element: app.secureTextFields["Password"],
            value: kcurrentUserPwd,
            clearText: false
        )
        app.buttons["Log in"].tap()
    }

    static func deleteMyApp() {
        let appName = "Stepik"

        // Put the app in the background
        // XCUIDevice.shared.press(XCUIDevice.Button.home)

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.icons[appName].waitForExistence(timeout: 5) {
            springboard.icons[appName].press(forDuration: 1.5)
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

    static func pasteTextFieldText(app: XCUIApplication, element: XCUIElement, value: String, clearText: Bool) {
        // Get the password into the pasteboard buffer
        UIPasteboard.init()
        UIPasteboard.general.string = value

        // Bring up the popup menu on the password field
        element.tap()

        if clearText {
            element.buttons["Clear text"].tap()
        }

        element.doubleTap()

        // Tap the Paste button to input the password
        app.menuItems["Paste"].tap()
    }
}
