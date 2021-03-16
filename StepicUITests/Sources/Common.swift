import Foundation
import XCTest

private var currentUserName: String?

enum Common {
    static func userName() -> String {
        if let currentUserName = currentUserName {
            return currentUserName
        }
        // register new user
        return currentUserName ?? "test"
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
