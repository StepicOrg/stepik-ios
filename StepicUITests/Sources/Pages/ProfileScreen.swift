import Foundation
import XCTest

final class ProfileScreen: BaseScreen {
    private lazy var singInButton = self.app.buttons[AccessibilityIdentifiers.Placeholders.loginButton]
    private lazy var settingsButton = self.app.buttons[AccessibilityIdentifiers.Profile.settingsButton]
    private lazy var logOutButton = self.app.tables.cells[AccessibilityIdentifiers.Settings.logOut]

    func clickSingIn() {
        XCTAssertTrue(self.singInButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Login' button")
        self.singInButton.tap()
    }

    func openSettings() {
        XCTAssertTrue(self.settingsButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Settings' button")
        self.settingsButton.tap()
    }

    func logOut() {
        self.app.swipeUp()
        self.logOutButton.tap()
        self.confirmAlert(text: "Выйти", button: "Выйти")
    }

    func shouldBeUserProfile(name: String) {
        self.shouldBeText(text: name)
    }

    func shouldBeSingInButton() {
        XCTAssertTrue(self.singInButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Login' button")
    }

    func isAuthorized() -> Bool {
        if self.singInButton.waitForExistence(timeout: Self.smallTimeout) {
            return false
        }
        return true
    }
}
