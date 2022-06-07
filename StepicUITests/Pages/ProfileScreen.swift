import Foundation
import XCTest

class ProfileScreen: BaseScreen {
    private lazy var singInButton = app.buttons[AccessibilityIdentifiers.Placeholders.loginButton]
    private lazy var settingsButton = app.buttons[AccessibilityIdentifiers.Profile.settingsButton]
    private lazy var logOutButton = app.tables.cells[AccessibilityIdentifiers.Settings.logOut]

    func clickSingIn() {
        XCTAssertTrue(self.singInButton.waitForExistence(timeout: 10), "No 'Login' button")
        self.singInButton.tap()
    }

    func openSettings() {
        XCTAssertTrue(self.settingsButton.waitForExistence(timeout: 10), "No 'Settings' button")
        self.settingsButton.tap()
    }

    func logOut() {
        app.swipeUp()
        self.logOutButton.tap()
        confirmAlert(text: "Выйти", button: "Выйти")
    }

    func shouldBeUserProfile(name: String) {
        shouldBeText(text: name)
    }

    func shouldBeSingInButton() {
        XCTAssertTrue(self.singInButton.waitForExistence(timeout: 10), "No 'Login' button")
    }

    func isAuthorized() -> Bool {
        if self.singInButton.waitForExistence(timeout: 5) {
            return false
        }
        return true
    }
}
