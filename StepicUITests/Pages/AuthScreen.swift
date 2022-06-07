import Foundation
import XCTest

class AuthScreen: BaseScreen {
    private lazy var loginWithEmailButton = app.buttons[AccessibilityIdentifiers.AuthSocial.signInButton]
    private lazy var registerButton = app.buttons[AccessibilityIdentifiers.AuthSocial.signUpButton]
    private lazy var googleButton = app.collectionViews.children(matching: .cell).element(boundBy: 2)

    func shouldBeAuthScreen() {
        XCTAssertTrue(self.loginWithEmailButton.waitForExistence(timeout: 10), "No 'Log in with email' button")
        XCTAssertTrue(self.registerButton.waitForExistence(timeout: 10), "No 'Register' button")
    }

    func clickRegister() {
        XCTAssertTrue(self.registerButton.waitForExistence(timeout: 10), "No 'Register' button")
        self.registerButton.tap()
    }

    func clickLoginWithEmail() {
        XCTAssertTrue(self.loginWithEmailButton.waitForExistence(timeout: 10), "No 'Log in with email' button")
        self.loginWithEmailButton.tap()
    }

    func clickLogInWithGoogle() {
        XCTAssertTrue(self.googleButton.waitForExistence(timeout: 10), "No 'Google' button")
        self.googleButton.tap()
    }
}
